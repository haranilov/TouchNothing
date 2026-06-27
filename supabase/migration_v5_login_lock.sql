-- TouchNothing v5: login rate limiting
-- Run once in Supabase Dashboard → SQL Editor after migration_v4
-- Safe to re-run (does not drop login_attempts data).

DROP FUNCTION IF EXISTS login_lock_health_check();

DROP FUNCTION IF EXISTS login_user (TEXT, TEXT);

DROP PROCEDURE IF EXISTS touch_login_failed_attempt (TEXT);

CREATE TABLE IF NOT EXISTS login_attempts (
  nickname TEXT NOT NULL,
  failed_count INTEGER NOT NULL DEFAULT 0,
  locked_until TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE login_attempts
  ADD COLUMN IF NOT EXISTS failed_count INTEGER NOT NULL DEFAULT 0;

ALTER TABLE login_attempts
  ADD COLUMN IF NOT EXISTS locked_until TIMESTAMPTZ;

ALTER TABLE login_attempts
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

DELETE FROM login_attempts a
USING login_attempts b
WHERE a.nickname = b.nickname
  AND a.ctid > b.ctid;

CREATE UNIQUE INDEX IF NOT EXISTS login_attempts_nickname_key
  ON login_attempts (nickname);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.login_attempts'::regclass
      AND contype = 'p'
  ) THEN
    ALTER TABLE login_attempts
      ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (nickname);
  END IF;
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'login_attempts primary key repair skipped: %', SQLERRM;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.login_attempts'::regclass
      AND conname = 'login_attempts_nickname_fkey'
  ) THEN
    ALTER TABLE login_attempts
      ADD CONSTRAINT login_attempts_nickname_fkey
      FOREIGN KEY (nickname) REFERENCES users (nickname) ON DELETE CASCADE;
  END IF;
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'login_attempts foreign key repair skipped: %', SQLERRM;
END;
$$;

ALTER TABLE login_attempts DISABLE ROW LEVEL SECURITY;
ALTER TABLE login_attempts OWNER TO postgres;

REVOKE ALL ON login_attempts FROM anon, authenticated;
GRANT ALL ON login_attempts TO postgres, service_role;

CREATE OR REPLACE FUNCTION auth_failure_response(p_error TEXT)
RETURNS JSONB
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT jsonb_build_object('ok', false, 'error', p_error);
$$;

CREATE OR REPLACE FUNCTION auth_success_response(
  p_nickname TEXT,
  p_session_token TEXT
)
RETURNS JSONB
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT jsonb_build_object(
    'ok', true,
    'nickname', p_nickname,
    'session_token', p_session_token
  );
$$;

CREATE OR REPLACE FUNCTION login_lock_error_for(p_nickname TEXT)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_locked_until TIMESTAMPTZ;
BEGIN
  SELECT locked_until
  INTO v_locked_until
  FROM login_attempts
  WHERE nickname = p_nickname;

  IF v_locked_until IS NOT NULL AND v_locked_until > NOW() THEN
    RETURN 'account_locked';
  END IF;

  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION increment_login_failed_attempt(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_failed_count INTEGER;
BEGIN
  SELECT failed_count
  INTO v_failed_count
  FROM login_attempts
  WHERE nickname = p_nickname
  FOR UPDATE;

  IF FOUND THEN
    v_failed_count := v_failed_count + 1;

    UPDATE login_attempts
    SET failed_count = v_failed_count,
        locked_until = CASE
          WHEN v_failed_count >= 5 THEN NOW() + INTERVAL '15 minutes'
          ELSE locked_until
        END,
        updated_at = NOW()
    WHERE nickname = p_nickname;
  ELSE
    INSERT INTO login_attempts (nickname, failed_count, updated_at)
    VALUES (p_nickname, 1, NOW());
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION clear_login_attempts(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_nickname TEXT;
BEGIN
  v_nickname := COALESCE(resolve_user_nickname(p_nickname), trim(p_nickname));
  DELETE FROM login_attempts WHERE nickname = v_nickname;
END;
$$;

CREATE OR REPLACE FUNCTION login_user(
  p_nickname TEXT,
  p_pin TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_nickname TEXT;
  v_pin_hash TEXT;
  v_lock_error TEXT;
BEGIN
  PERFORM assert_valid_pin(p_pin);

  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RETURN auth_failure_response('invalid_credentials');
  END IF;

  SELECT pin_hash
  INTO v_pin_hash
  FROM users
  WHERE nickname = v_nickname;

  v_lock_error := login_lock_error_for(v_nickname);
  IF v_lock_error IS NOT NULL THEN
    RETURN auth_failure_response(v_lock_error);
  END IF;

  IF v_pin_hash <> crypt(p_pin, v_pin_hash) THEN
    PERFORM increment_login_failed_attempt(v_nickname);
    RETURN auth_failure_response('invalid_credentials');
  END IF;

  PERFORM clear_login_attempts(v_nickname);

  RETURN auth_success_response(
    v_nickname,
    issue_session_token(v_nickname)
  );
END;
$$;

CREATE OR REPLACE FUNCTION check_login_lock(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_nickname TEXT;
  v_lock_error TEXT;
BEGIN
  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RETURN;
  END IF;

  v_lock_error := login_lock_error_for(v_nickname);
  IF v_lock_error IS NOT NULL THEN
    RAISE EXCEPTION '%', v_lock_error;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION record_failed_login(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_nickname TEXT;
BEGIN
  v_nickname := COALESCE(resolve_user_nickname(p_nickname), trim(p_nickname));
  PERFORM increment_login_failed_attempt(v_nickname);
END;
$$;

CREATE OR REPLACE FUNCTION login_lock_health_check()
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'login_attempts_table', EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'login_attempts'
    ),
    'login_user_has_lock_logic', EXISTS (
      SELECT 1
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public'
        AND p.proname = 'login_user'
        AND pg_get_functiondef(p.oid) LIKE '%increment_login_failed_attempt%'
    )
  );
$$;

ALTER FUNCTION auth_failure_response(TEXT) OWNER TO postgres;
ALTER FUNCTION auth_success_response(TEXT, TEXT) OWNER TO postgres;
ALTER FUNCTION login_lock_error_for(TEXT) OWNER TO postgres;
ALTER FUNCTION increment_login_failed_attempt(TEXT) OWNER TO postgres;
ALTER FUNCTION clear_login_attempts(TEXT) OWNER TO postgres;
ALTER FUNCTION check_login_lock(TEXT) OWNER TO postgres;
ALTER FUNCTION record_failed_login(TEXT) OWNER TO postgres;
ALTER FUNCTION login_user(TEXT, TEXT) OWNER TO postgres;

GRANT EXECUTE ON FUNCTION login_user (TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION login_lock_health_check () TO anon, authenticated;
