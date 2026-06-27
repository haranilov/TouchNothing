#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

PKG="com.touchnothing.app"
ACTIVITY="$PKG/.MainActivity"
OUT_DIR="$ROOT/store-assets/screenshots/phone"

mkdir -p "$OUT_DIR"

log() { printf '[screenshots] %s\n' "$*"; }

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
  [[ -n "$coords" ]] || return 1
  adb shell input tap $coords
}

wait_for_text() {
  local label="$1"
  local timeout="${2:-30}"
  for ((i = 0; i < timeout; i++)); do
    ui_dump | grep -Fq "text=\"$label\"" && return 0
    sleep 1
  done
  return 1
}

capture() {
  local name="$1"
  sleep 1
  adb exec-out screencap -p > "$OUT_DIR/$name.png"
  log "Saved $name.png"
}

cd "$ROOT"
./gradlew installDebug -q
adb shell pm grant "$PKG" android.permission.READ_PHONE_STATE || true
adb shell pm clear "$PKG" >/dev/null
adb shell am start -n "$ACTIVITY" >/dev/null
sleep 2

wait_for_text "Guest" 15
tap_text "Guest"
sleep 1
capture "01_auth_guest"

tap_text "Continue as Guest"
wait_for_text "Start" 45
capture "02_main_menu"

tap_text "Leaderboard"
wait_for_text "Leaderboard" 10 || true
sleep 2
capture "03_leaderboard"
adb shell input keyevent 4
sleep 1

tap_text "My Total"
wait_for_text "My Total" 10 || true
sleep 2
capture "04_my_total"
adb shell input keyevent 4
sleep 1

tap_text "Start"
sleep 1
if ui_dump | grep -Fq 'text="I understand. Start."'; then
  tap_text "Don't show again" || true
  sleep 0.5
  capture "05_rules"
  tap_text "I understand. Start."
  sleep 1
fi

if ui_dump | grep -Fq 'text="Detect phone calls?"'; then
  tap_text "Allow" || true
  sleep 1
fi

capture "06_session"
adb shell input tap 540 1200
sleep 1
capture "07_session_result"

log "Done: $OUT_DIR"
