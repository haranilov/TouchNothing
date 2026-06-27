-- TouchNothing v6: show remaining login attempts in API response
-- Run once in Supabase Dashboard → SQL Editor after migration_v5
-- Safe to re-run.

DROP FUNCTION IF EXISTS login_user (TEXT, TEXT);
DROP FUNCTION IF EXISTS record_failed_login (TEXT);
DROP FUNCTION IF EXISTS increment_login_failed_attempt (TEXT);
DROP FUNCTION IF EXISTS auth_failure_response (TEXT);
DROP FUNCTION IF EXISTS auth_failure_response (TEXT, INTEGER);

CREATE OR REPLACE FUNCTION login_max_failed_attempts()
RETURNS INTEGER
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT 5;
$$;

CREATE OR REPLACE FUNCTION auth_failure_response(
  p_error TEXT,
  p_remaining_attempts INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN p_remaining_attempts IS NULL THEN
      jsonb_build_object('ok', false, 'error', p_error)
    ELSE
      jsonb_build_object(
        'ok', false,
        'error', p_error,
        'remaining_attempts', p_remaining_attempts
      )
  END;
$$;

CREATE OR REPLACE FUNCTION increment_login_failed_attempt(p_nickname TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_failed_count INTEGER;
  v_max_attempts INTEGER;
BEGIN
  v_max_attempts := login_max_failed_attempts();

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
          WHEN v_failed_count >= v_max_attempts THEN NOW() + INTERVAL '15 minutes'
          ELSE locked_until
        END,
        updated_at = NOW()
    WHERE nickname = p_nickname;
  ELSE
    v_failed_count := 1;

    INSERT INTO login_attempts (nickname, failed_count, updated_at)
    VALUES (p_nickname, v_failed_count, NOW());
  END IF;

  RETURN GREATEST(0, v_max_attempts - v_failed_count);
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
  v_remaining_attempts INTEGER;
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
    v_remaining_attempts := increment_login_failed_attempt(v_nickname);

    IF v_remaining_attempts <= 0 THEN
      RETURN auth_failure_response('account_locked');
    END IF;

    RETURN auth_failure_response('invalid_credentials', v_remaining_attempts);
  END IF;

  PERFORM clear_login_attempts(v_nickname);

  RETURN auth_success_response(
    v_nickname,
    issue_session_token(v_nickname)
  );
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

ALTER FUNCTION login_max_failed_attempts() OWNER TO postgres;
ALTER FUNCTION auth_failure_response(TEXT, INTEGER) OWNER TO postgres;
ALTER FUNCTION increment_login_failed_attempt(TEXT) OWNER TO postgres;
ALTER FUNCTION login_user(TEXT, TEXT) OWNER TO postgres;
ALTER FUNCTION record_failed_login(TEXT) OWNER TO postgres;

GRANT EXECUTE ON FUNCTION login_user (TEXT, TEXT) TO anon, authenticated;
