-- TouchNothing v3: session tokens for submit_session
-- Run once in Supabase Dashboard → SQL Editor after migration_v2

CREATE TABLE IF NOT EXISTS user_sessions (
  nickname TEXT PRIMARY KEY REFERENCES users (nickname) ON DELETE CASCADE,
  token_hash TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION issue_session_token(p_nickname TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_token TEXT;
BEGIN
  v_token := replace(gen_random_uuid()::text, '-', '')
    || replace(gen_random_uuid()::text, '-', '');

  INSERT INTO user_sessions (nickname, token_hash)
  VALUES (p_nickname, crypt(v_token, gen_salt('bf')))
  ON CONFLICT (nickname) DO UPDATE
  SET
    token_hash = EXCLUDED.token_hash,
    updated_at = NOW();

  RETURN v_token;
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
  v_token_hash TEXT;
BEGIN
  IF p_session_token IS NULL OR char_length(p_session_token) < 32 THEN
    RAISE EXCEPTION 'invalid_session_token';
  END IF;

  SELECT token_hash
  INTO v_token_hash
  FROM user_sessions
  WHERE nickname = p_nickname;

  IF v_token_hash IS NULL OR v_token_hash <> crypt(p_session_token, v_token_hash) THEN
    RAISE EXCEPTION 'invalid_session_token';
  END IF;
END;
$$;

DROP FUNCTION IF EXISTS register_user (TEXT, TEXT);
DROP FUNCTION IF EXISTS login_user (TEXT, TEXT);
DROP FUNCTION IF EXISTS submit_session (TEXT, INTEGER);

CREATE OR REPLACE FUNCTION register_user(
  p_nickname TEXT,
  p_pin TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  PERFORM assert_valid_pin(p_pin);

  IF char_length(p_nickname) < 2 OR char_length(p_nickname) > 24 THEN
    RAISE EXCEPTION 'invalid_nickname';
  END IF;

  IF EXISTS (SELECT 1 FROM users WHERE nickname = p_nickname) THEN
    RAISE EXCEPTION 'nickname_taken';
  END IF;

  INSERT INTO users (nickname, pin_hash)
  VALUES (p_nickname, crypt(p_pin, gen_salt('bf')));

  INSERT INTO user_stats (nickname)
  VALUES (p_nickname);

  RETURN issue_session_token(p_nickname);
END;
$$;

CREATE OR REPLACE FUNCTION login_user(
  p_nickname TEXT,
  p_pin TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_pin_hash TEXT;
BEGIN
  PERFORM assert_valid_pin(p_pin);

  SELECT pin_hash
  INTO v_pin_hash
  FROM users
  WHERE nickname = p_nickname;

  IF v_pin_hash IS NULL THEN
    RAISE EXCEPTION 'invalid_credentials';
  END IF;

  PERFORM check_login_lock(p_nickname);

  IF v_pin_hash <> crypt(p_pin, v_pin_hash) THEN
    PERFORM record_failed_login(p_nickname);
    RAISE EXCEPTION 'invalid_credentials';
  END IF;

  PERFORM clear_login_attempts(p_nickname);

  RETURN issue_session_token(p_nickname);
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
BEGIN
  IF p_duration < 5 THEN
    RETURN;
  END IF;

  PERFORM verify_session_token(p_nickname, p_session_token);

  IF NOT EXISTS (SELECT 1 FROM users WHERE nickname = p_nickname) THEN
    RAISE EXCEPTION 'nickname_not_registered';
  END IF;

  INSERT INTO records (nickname, duration_seconds)
  VALUES (p_nickname, p_duration)
  ON CONFLICT (nickname) DO UPDATE
  SET
    duration_seconds = EXCLUDED.duration_seconds,
    updated_at = NOW()
  WHERE EXCLUDED.duration_seconds > records.duration_seconds;

  INSERT INTO user_stats (nickname, total_duration_seconds, session_count)
  VALUES (p_nickname, p_duration, 1)
  ON CONFLICT (nickname) DO UPDATE
  SET
    total_duration_seconds = user_stats.total_duration_seconds + EXCLUDED.total_duration_seconds,
    session_count = user_stats.session_count + 1,
    updated_at = NOW();
END;
$$;

GRANT EXECUTE ON FUNCTION issue_session_token (TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION verify_session_token (TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION register_user (TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION login_user (TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION submit_session (TEXT, INTEGER, TEXT) TO anon, authenticated;
