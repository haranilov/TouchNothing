#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$ROOT/TouchNothing/Resources/SupabaseSecrets.plist"
BASE_URL="$(/usr/libexec/PlistBuddy -c 'Print :SUPABASE_URL' "$PLIST")/rest/v1"
API_KEY="$(/usr/libexec/PlistBuddy -c 'Print :SUPABASE_ANON_KEY' "$PLIST")"
TEST_NICK="CiTest_$(date +%s)"
TEST_PIN="5678"

auth_headers=(
  -H "apikey: $API_KEY"
  -H "Authorization: Bearer $API_KEY"
  -H "Content-Type: application/json"
)

request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="$BASE_URL$path"

  if [[ -n "$body" ]]; then
    curl -s -o /tmp/tn_body.txt -w "%{http_code}" -X "$method" "$url" "${auth_headers[@]}" -d "$body"
  else
    curl -s -o /tmp/tn_body.txt -w "%{http_code}" -X "$method" "$url" "${auth_headers[@]}"
  fi
}

assert_status() {
  local label="$1"
  local expected="$2"
  local actual="$3"

  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: $label (expected $expected, got $actual)"
    cat /tmp/tn_body.txt || true
    exit 1
  fi

  echo "PASS: $label"
}

parse_session_token() {
  python3 -c "import json; data=json.load(open('/tmp/tn_body.txt')); print(data['session_token'] if isinstance(data, dict) else data)"
}

parse_session_nickname() {
  local fallback="$1"
  python3 -c "import json, sys; data=json.load(open('/tmp/tn_body.txt')); print(data['nickname'] if isinstance(data, dict) else sys.argv[1])" "$fallback"
}

auth_response_is_json_object() {
  python3 -c "import json; print(isinstance(json.load(open('/tmp/tn_body.txt')), dict))"
}

echo "== Supabase API integration tests =="

status="$(request GET "/records?select=nickname&limit=1")"
assert_status "records readable" "200" "$status"

status="$(request GET "/user_stats?select=nickname&limit=1")"
assert_status "user_stats readable" "200" "$status"

status="$(request POST "/rpc/register_user" "{\"p_nickname\":\"$TEST_NICK\",\"p_pin\":\"$TEST_PIN\"}")"
assert_status "register_user" "200" "$status"
SESSION_TOKEN="$(parse_session_token)"

if [[ "$(auth_response_is_json_object)" == "True" ]]; then
  status="$(request POST "/rpc/login_user" "{\"p_nickname\":\"$(echo "$TEST_NICK" | tr '[:upper:]' '[:lower:]')\",\"p_pin\":\"$TEST_PIN\"}")"
  assert_status "login_user accepts nickname case-insensitively" "200" "$status"
  LOGIN_NICK="$(parse_session_nickname "$TEST_NICK")"
  if [[ "$LOGIN_NICK" != "$TEST_NICK" ]]; then
    echo "FAIL: login_user returned canonical nickname (expected $TEST_NICK, got $LOGIN_NICK)"
    exit 1
  fi
  echo "PASS: login_user returns canonical nickname"
  SESSION_TOKEN="$(parse_session_token)"
else
  echo "SKIP: case-insensitive login (apply migration_v4_case_insensitive_nickname.sql)"
fi

status="$(request POST "/rpc/login_user" "{\"p_nickname\":\"$TEST_NICK\",\"p_pin\":\"wrong\"}")"
assert_status "login_user rejects wrong pin" "400" "$status"

status="$(request POST "/rpc/submit_session" "{\"p_nickname\":\"$TEST_NICK\",\"p_duration\":12,\"p_session_token\":\"$SESSION_TOKEN\"}")"
assert_status "submit_session" "204" "$status"

status="$(request POST "/rpc/get_user_stats" "{\"p_nickname\":\"$(echo "$TEST_NICK" | tr '[:upper:]' '[:lower:]')\"}")"
assert_status "get_user_stats" "200" "$status"

status="$(request DELETE "/users?nickname=eq.$TEST_NICK")"
assert_status "cleanup test user" "204" "$status"

echo "All integration tests passed."
