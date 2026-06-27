# Play Store listing — TouchNothing

Use this when creating the app in [Google Play Console](https://play.google.com/console).

## App details

| Field | Value |
|-------|-------|
| **App name** | TouchNothing |
| **Package** | `com.touchnothing.app` |
| **Category** | Games → Casual (or Puzzle) |
| **Privacy policy URL** | https://github.com/haranilov/TouchNothing/blob/main/PRIVACY.md |
| **Contact** | https://github.com/haranilov/TouchNothing/issues |

## Short description (max 80 characters)

```
Open the app. Touch nothing. The longer you last, the higher you rank.
```

(72 characters)

## Full description

```
TouchNothing is a minimalist challenge: open the app and don't touch the screen.

HOW IT WORKS
• Start a session and put your phone down
• The timer runs while you stay in the app and touch nothing
• If you tap the screen, leave the app, or get a phone call — the session ends
• Compete on the leaderboard for best session and all-time total

FEATURES
• Simple black-screen gameplay — no distractions
• Global leaderboards (best session and all-time)
• Personal stats with total time and session count
• Create an account with a nickname and PIN, or play as Guest
• Optional call detection ends your session on incoming calls

TIP
For fewer interruptions, turn on Airplane Mode and turn off Wi-Fi during a session.

No ads. No tracking. Just you and the timer.
```

## Graphics

| Asset | Path / spec |
|-------|-------------|
| App icon | `app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp` (upload 512×512 PNG export) |
| Phone screenshots | `store-assets/screenshots/phone/01–07` (1080×2400) |
| 7-inch tablet screenshots | `store-assets/screenshots/tablet-7/01–07` (1200×1920) |
| 10-inch tablet screenshots | `store-assets/screenshots/tablet-10/01–07` (1600×2560) |

Regenerate tablet assets: `bash scripts/generate-tablet-screenshots.sh`
| Feature graphic | 1024×500 PNG — optional; not included in repo |

Screenshot order for Play Console:

1. `01_auth_sign_in.png` — Sign in
2. `02_main_menu.png` — Main menu
3. `03_leaderboard.png` — Leaderboard
4. `04_my_total.png` — Personal stats
5. `05_rules.png` — Rules
6. `06_session.png` — Active session
7. `07_session_result.png` — Session result

## Release binary

```
app/build/outputs/bundle/release/app-release.aab
```

Build: `./gradlew bundleRelease` (requires signing in `local.properties`).

Version: **1.0.0** (versionCode **1**)

## Permissions — declaration for Play Console

### READ_PHONE_STATE (optional)

**Why:** End the game session when an incoming cellular call arrives, as stated in the in-app rules.

**Not used for:** Reading phone numbers, call logs, contacts, or placing calls.

**Note:** VoIP calls (WhatsApp, Telegram, etc.) are detected via audio focus without this permission. Users can deny the permission and still play.

## Data safety (questionnaire hints)

| Question | Answer |
|----------|--------|
| Collects or shares user data? | Yes — account and gameplay data |
| Data types | User IDs (nickname), app activity (session times, scores) |
| Encrypted in transit | Yes (HTTPS) |
| Users can request deletion | Yes — via GitHub issues (see privacy policy) |
| Purpose | App functionality, account management, leaderboards |
| Sold to third parties | No |
| Used for advertising | No |
| Used for tracking | No |

## Content rating

Expected: **Everyone** / PEGI 3 / similar.

- No violence, gambling, user-generated content, or social features beyond public nicknames on leaderboards.

## Upload checklist

- [ ] Create app in Play Console
- [ ] Upload `app-release.aab` to Internal testing (or Production)
- [ ] Add short + full description
- [ ] Upload 7 phone screenshots
- [ ] Set privacy policy URL
- [ ] Complete Data safety form
- [ ] Complete Content rating questionnaire
- [ ] Declare `READ_PHONE_STATE` with justification above
- [ ] Review and roll out
