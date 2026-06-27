#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

PKG="com.touchnothing.app"
ACTIVITY="$PKG/.MainActivity"
OUT_DIR="$ROOT/store-assets/screenshots/phone"
SCREENSHOT_NICKNAME="${SCREENSHOT_NICKNAME:-Kos}"
SCREENSHOT_PIN="${SCREENSHOT_PIN:-1023}"

mkdir -p "$OUT_DIR"

log() { printf '[screenshots] %s\n' "$*"; }

ui_dump() {
  local xml=""
  for _ in 1 2 3; do
    if adb shell uiautomator dump /sdcard/tn-ui.xml >/dev/null 2>&1; then
      xml="$(adb shell cat /sdcard/tn-ui.xml | tr -d '\r')"
      [[ -n "$xml" ]] && printf '%s' "$xml" && return 0
    fi
    sleep 1
  done
  return 1
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

tap_clickable() {
  local label="$1"
  local xml coords
  xml="$(ui_dump)"
  coords="$(printf '%s' "$xml" | python3 -c "
import sys, xml.etree.ElementTree as ET, re
label = sys.argv[1]
root = ET.fromstring(sys.stdin.read())
for node in root.iter('node'):
    texts = [child.attrib.get('text', '') for child in node.iter('node')]
    if label not in texts:
        continue
    if node.attrib.get('clickable') != 'true':
        continue
    match = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', node.attrib.get('bounds', ''))
    if not match:
        continue
    x1, y1, x2, y2 = map(int, match.groups())
    print(f'{(x1 + x2) // 2} {(y1 + y2) // 2}')
    raise SystemExit
for node in root.iter('node'):
    if node.attrib.get('text') != label:
        continue
    match = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', node.attrib.get('bounds', ''))
    if not match:
        continue
    x1, y1, x2, y2 = map(int, match.groups())
    print(f'{(x1 + x2) // 2} {(y1 + y2) // 2}')
    break
" "$label")"
  [[ -n "$coords" ]] || return 1
  adb shell input tap $coords
}

tap_edit_field() {
  local index="$1"
  local xml coords
  xml="$(ui_dump)"
  coords="$(printf '%s' "$xml" | python3 -c "
import sys, xml.etree.ElementTree as ET, re
index = int(sys.argv[1])
root = ET.fromstring(sys.stdin.read())
fields = [node for node in root.iter('node') if 'EditText' in node.attrib.get('class', '')]
if index >= len(fields):
    raise SystemExit(1)
node = fields[index]
match = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', node.attrib.get('bounds', ''))
if not match:
    raise SystemExit(1)
x1, y1, x2, y2 = map(int, match.groups())
print(f'{(x1 + x2) // 2} {(y1 + y2) // 2}')
" "$index")"
  [[ -n "$coords" ]] || return 1
  adb shell input tap $coords
}

set_edit_field() {
  local index="$1"
  local value="$2"
  tap_edit_field "$index"
  sleep 0.3
  adb shell input keyevent 123
  for _ in $(seq 1 32); do
    adb shell input keyevent 67
  done
  adb shell input text "$value"
  sleep 0.3
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

hide_keyboard() {
  adb shell input keyevent 4
  sleep 0.4
}

ensure_sign_in_mode() {
  wait_for_text "Sign In" 15
  for _ in 1 2 3; do
    if ui_dump | grep -Fq 'text="Confirm PIN"'; then
      tap_text "Sign In"
      sleep 0.8
    fi
    ui_dump | grep -Fq "PIN cannot be recovered" && return 0
  done
  return 1
}

capture() {
  local name="$1"
  sleep 1
  adb exec-out screencap -p > "$OUT_DIR/$name.png"
  log "Saved $name.png"
}

sign_in_as_kos() {
  ensure_sign_in_mode
  set_edit_field 0 "$SCREENSHOT_NICKNAME"
  set_edit_field 1 "$SCREENSHOT_PIN"
  hide_keyboard
}

cd "$ROOT"
./gradlew installDebug -q
adb shell pm grant "$PKG" android.permission.READ_PHONE_STATE || true
adb shell pm clear "$PKG" >/dev/null
adb shell am start -n "$ACTIVITY" >/dev/null
sleep 3

sign_in_as_kos
capture "01_auth_sign_in"

tap_clickable "Continue"
hide_keyboard
wait_for_text "Start" 45
capture "02_main_menu"

tap_clickable "Leaderboard"
wait_for_text "Leaderboard" 10 || true
sleep 2
capture "03_leaderboard"
adb shell input keyevent 4
sleep 1

tap_clickable "My Total"
wait_for_text "My Total" 10 || true
sleep 2
capture "04_my_total"
adb shell input keyevent 4
sleep 1

tap_clickable "Start"
sleep 1
if ui_dump | grep -Fq 'text="I understand. Start."'; then
  capture "05_rules"
  tap_clickable "Don't show again" || true
  sleep 0.5
  tap_clickable "I understand. Start."
  sleep 1
fi

if ui_dump | grep -Fq 'text="Detect phone calls?"'; then
  tap_clickable "Not now" || tap_clickable "Allow" || true
  sleep 1
fi

sleep 2
capture "06_session"
adb shell input tap 540 1200
wait_for_text "You lasted" 15 || wait_for_text "Back to menu" 15
sleep 2
capture "07_session_result"

rm -f "$OUT_DIR/01_auth_guest.png"
log "Done: $OUT_DIR (account: $SCREENSHOT_NICKNAME)"
