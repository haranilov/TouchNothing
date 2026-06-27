-- TouchNothing: keep only kos, pool, brahma
-- Run in Supabase Dashboard → SQL Editor (postgres role)

-- 1) Preview what will be deleted
SELECT nickname
FROM users
WHERE lower(nickname) NOT IN ('kos', 'pool', 'brahma')
ORDER BY nickname;

-- 2) Delete everyone else (stats, records, sessions, login_attempts cascade)
DELETE FROM users
WHERE lower(nickname) NOT IN ('kos', 'pool', 'brahma');

-- 3) Verify
SELECT nickname
FROM users
ORDER BY nickname;
