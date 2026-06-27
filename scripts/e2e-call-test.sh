#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

PKG="com.touchnothing.app"
ACTIVITY="$PKG/.MainActivity"
AVD="${AVD:-TouchNothing_API35}"

log() { printf '[e2e] %s\n' "$*"; }
fail() { printf '[e2e] FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf '[e2e] PASS: %s\n' "$*"; }

restart_emulator() {
  if [[ "${RESTART_EMULATOR:-0}" == "1" ]]; then
    log "Restarting emulator ($AVD)..."
    adb devices | grep -q emulator && adb -s emulator-5554 emu kill || true
    sleep 2
    nohup emulator -avd "$AVD" -no-boot-anim >/tmp/touchnothing-emulator.log 2>&1 &
    adb wait-for-device
    until [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do sleep 2; done
    log "Emulator ready"
  else
    log "Using running emulator (set RESTART_EMULATOR=1 to cold restart)"
    adb wait-for-device
    until [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do sleep 2; done
  fi
}

ui_dump() {
  adb shell uiautomator dump /sdcard/tn-ui.xml >/dev/null
  adb shell cat /sdcard/tn-ui.xml | tr -d '\r'
}

tap_text() {
  local label="$1"
  local xml coords
  xml="$(ui_dump)"
  coords="$(printf '%s' "$xml" | python3 -c "
import sys, xml.etree.ElementTree as ET, re
label = sys.argv[1]
root = ET.fromstring(sys.stdin.read())
for node in root.iter('node'):
    if node.attrib.get('text') != label:
        continue
    bounds = node.attrib.get('bounds', '')
    match = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
    if not match:
        continue
    x1, y1, x2, y2 = map(int, match.groups())
    print(f'{(x1 + x2) // 2} {(y1 + y2) // 2}')
    break
" "$label")"
  if [[ -z "$coords" ]]; then
    return 1
  fi
  log "Tapping \"$label\" at $coords"
  adb shell input tap $coords
  return 0
}

wait_for_text() {
  local label="$1"
  local timeout="${2:-30}"
  local i xml
  for ((i = 0; i < timeout; i++)); do
    xml="$(ui_dump)"
    if printf '%s' "$xml" | grep -Fq "text=\"$label\""; then
      return 0
    fi
    sleep 1
  done
  return 1
}

screen_has_text() {
  local label="$1"
  ui_dump | grep -Fq "text=\"$label\""
}

install_app() {
  log "Installing debug build..."
  cd "$ROOT"
  ./gradlew installDebug -q
  adb shell pm grant "$PKG" android.permission.READ_PHONE_STATE || true
}

login_as_guest() {
  log "Logging in as guest..."
  adb shell pm clear "$PKG" >/dev/null
  adb shell am start -n "$ACTIVITY" >/dev/null

  wait_for_text "Guest" 15 || fail "Auth screen did not open"
  tap_text "Guest" || fail "Could not tap Guest tab"

  wait_for_text "Continue as Guest" 10 || fail "Guest form did not appear"
  tap_text "Continue as Guest" || fail "Could not tap Continue as Guest"

  if wait_for_text "Start" 45; then
    pass "Guest login completed (main menu visible)"
    return 0
  fi

  ui_dump | grep -Fq 'text="Setting up guest' && fail "Guest setup is still in progress after timeout"
  fail "Main menu did not appear after guest login"
}

dismiss_phone_permission_if_needed() {
  if screen_has_text "Detect phone calls?"; then
    log "Confirming in-app phone permission rationale..."
    tap_text "Allow" || true
    sleep 1
  fi
  if screen_has_text "make and manage phone calls"; then
    log "Confirming system phone permission dialog..."
    tap_text "Allow" || adb shell pm grant "$PKG" android.permission.READ_PHONE_STATE
    sleep 1
  fi
}

start_session() {
  log "Starting session from main menu..."
  screen_has_text "Start" || fail "Not on main menu before session start"

  tap_text "Start" || fail "Could not tap Start on main menu"
  sleep 1

  if screen_has_text "I understand. Start."; then
    log "Rules screen detected"
    tap_text "Don't show again" || true
    tap_text "I understand. Start." || fail "Could not confirm rules"
    sleep 1
  fi

  dismiss_phone_permission_if_needed

  if screen_has_text "Start" || screen_has_text "Guest" || screen_has_text "Continue as Guest"; then
    fail "Still on menu/auth after trying to start session"
  fi

  pass "Session screen is active (black screen)"
}

assert_session_ended() {
  local i xml
  for ((i = 0; i < 10; i++)); do
    sleep 1
    xml="$(ui_dump)"
    if echo "$xml" | grep -q 'Back to menu'; then
      pass "Session ended after incoming call"
      return 0
    fi
    if echo "$xml" | grep -q 'You lasted'; then
      pass "Session ended after incoming call (result visible)"
      return 0
    fi
    if echo "$xml" | grep -q 'Sessions under'; then
      pass "Session ended after incoming call (short session message)"
      return 0
    fi
  done
  fail "Session did not end after simulated call"
}

test_incoming_call() {
  log "Simulating incoming GSM call..."
  adb emu gsm call 15555215554
  assert_session_ended
  adb emu gsm cancel 15555215554 || true
  sleep 1
}

main() {
  restart_emulator
  install_app
  login_as_guest
  start_session
  test_incoming_call
  log "All E2E call checks passed"
}

main "$@"
