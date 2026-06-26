-- TouchNothing v4: case-insensitive nickname matching
-- Run once in Supabase Dashboard → SQL Editor after migration_v3

CREATE OR REPLACE FUNCTION resolve_user_nickname(p_nickname TEXT)
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT u.nickname
  FROM users u
  WHERE lower(u.nickname) = lower(trim(p_nickname))
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION check_login_lock(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_nickname TEXT;
  v_locked_until TIMESTAMPTZ;
BEGIN
  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RETURN;
  END IF;

  SELECT locked_until
  INTO v_locked_until
  FROM login_attempts
  WHERE nickname = v_nickname;

  IF v_locked_until IS NOT NULL AND v_locked_until > NOW() THEN
    RAISE EXCEPTION 'account_locked';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION record_failed_login(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_nickname TEXT;
BEGIN
  v_nickname := COALESCE(resolve_user_nickname(p_nickname), trim(p_nickname));

  INSERT INTO login_attempts (nickname, failed_count)
  VALUES (v_nickname, 1)
  ON CONFLICT (nickname) DO UPDATE
  SET failed_count = login_attempts.failed_count + 1,
      locked_until = CASE
        WHEN login_attempts.failed_count + 1 >= 5 THEN NOW() + INTERVAL '15 minutes'
        ELSE login_attempts.locked_until
      END;
END;
$$;

CREATE OR REPLACE FUNCTION clear_login_attempts(p_nickname TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_nickname TEXT;
BEGIN
  v_nickname := COALESCE(resolve_user_nickname(p_nickname), trim(p_nickname));
  DELETE FROM login_attempts WHERE nickname = v_nickname;
END;
$$;

CREATE OR REPLACE FUNCTION verify_session_token(
  p_nickname TEXT,
  p_session_token TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_nickname TEXT;
  v_token_hash TEXT;
BEGIN
  IF p_session_token IS NULL OR char_length(p_session_token) < 32 THEN
    RAISE EXCEPTION 'invalid_session_token';
  END IF;

  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RAISE EXCEPTION 'invalid_session_token';
  END IF;

  SELECT token_hash
  INTO v_token_hash
  FROM user_sessions
  WHERE nickname = v_nickname;

  IF v_token_hash IS NULL OR v_token_hash <> crypt(p_session_token, v_token_hash) THEN
    RAISE EXCEPTION 'invalid_session_token';
  END IF;
END;
$$;

DROP FUNCTION IF EXISTS register_user (TEXT, TEXT);
DROP FUNCTION IF EXISTS login_user (TEXT, TEXT);

CREATE OR REPLACE FUNCTION register_user(
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
BEGIN
  PERFORM assert_valid_pin(p_pin);

  v_nickname := trim(p_nickname);

  IF char_length(v_nickname) < 2 OR char_length(v_nickname) > 24 THEN
    RAISE EXCEPTION 'invalid_nickname';
  END IF;

  IF resolve_user_nickname(v_nickname) IS NOT NULL THEN
    RAISE EXCEPTION 'nickname_taken';
  END IF;

  INSERT INTO users (nickname, pin_hash)
  VALUES (v_nickname, crypt(p_pin, gen_salt('bf')));

  INSERT INTO user_stats (nickname)
  VALUES (v_nickname);

  RETURN jsonb_build_object(
    'session_token', issue_session_token(v_nickname),
    'nickname', v_nickname
  );
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
BEGIN
  PERFORM assert_valid_pin(p_pin);

  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RAISE EXCEPTION 'invalid_credentials';
  END IF;

  SELECT pin_hash
  INTO v_pin_hash
  FROM users
  WHERE nickname = v_nickname;

  PERFORM check_login_lock(v_nickname);

  IF v_pin_hash <> crypt(p_pin, v_pin_hash) THEN
    PERFORM record_failed_login(v_nickname);
    RAISE EXCEPTION 'invalid_credentials';
  END IF;

  PERFORM clear_login_attempts(v_nickname);

  RETURN jsonb_build_object(
    'session_token', issue_session_token(v_nickname),
    'nickname', v_nickname
  );
END;
$$;

CREATE OR REPLACE FUNCTION submit_session(
  p_nickname TEXT,
  p_duration INTEGER,
  p_session_token TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_nickname TEXT;
BEGIN
  IF p_duration < 5 THEN
    RETURN;
  END IF;

  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RAISE EXCEPTION 'nickname_not_registered';
  END IF;

  PERFORM verify_session_token(v_nickname, p_session_token);

  INSERT INTO records (nickname, duration_seconds)
  VALUES (v_nickname, p_duration)
  ON CONFLICT (nickname) DO UPDATE
  SET
    duration_seconds = EXCLUDED.duration_seconds,
    updated_at = NOW()
  WHERE EXCLUDED.duration_seconds > records.duration_seconds;

  INSERT INTO user_stats (nickname, total_duration_seconds, session_count)
  VALUES (v_nickname, p_duration, 1)
  ON CONFLICT (nickname) DO UPDATE
  SET
    total_duration_seconds = user_stats.total_duration_seconds + EXCLUDED.total_duration_seconds,
    session_count = user_stats.session_count + 1,
    updated_at = NOW();
END;
$$;

CREATE OR REPLACE FUNCTION get_user_stats(p_nickname TEXT)
RETURNS TABLE (
  total_duration_seconds BIGINT,
  session_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  v_nickname TEXT;
BEGIN
  v_nickname := resolve_user_nickname(p_nickname);
  IF v_nickname IS NULL THEN
    RETURN QUERY SELECT 0::BIGINT, 0::INTEGER;
    RETURN;
  END IF;

  RETURN QUERY
  SELECT us.total_duration_seconds, us.session_count
  FROM user_stats us
  WHERE us.nickname = v_nickname;

  IF NOT FOUND THEN
    RETURN QUERY SELECT 0::BIGINT, 0::INTEGER;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION resolve_user_nickname (TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION register_user (TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION login_user (TEXT, TEXT) TO anon, authenticated;
