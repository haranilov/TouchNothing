# TouchNothing (Android)

Minimalist game: open the app and touch nothing. The longer you last, the higher you rank.

## Setup

1. Install [Android Studio](https://developer.android.com/studio) (or Android SDK + JDK 17).
2. Copy `local.properties.example` to `local.properties` and fill in:
   - `sdk.dir` — path to your Android SDK
   - `SUPABASE_URL` — your Supabase project URL
   - `SUPABASE_ANON_KEY` — your Supabase anon key
3. Open this folder in Android Studio, or build from the command line:

```bash
./gradlew assembleDebug
./gradlew installDebug
```

## Tests

```bash
./gradlew testDebugUnitTest lintDebug
./gradlew connectedDebugAndroidTest          # requires a running emulator/device
bash scripts/e2e-call-test.sh                # guest login → session → simulated call
bash scripts/capture-play-screenshots.sh     # Play Store screenshots → store-assets/
```

## Release build (Play Store)

1. Create a release keystore (once):

```bash
keytool -genkey -v -keystore release.keystore -alias touchnothing -keyalg RSA -keysize 2048 -validity 10000
```

2. Add signing fields to `local.properties` (see `local.properties.example`).
3. Build the App Bundle:

```bash
./gradlew bundleRelease
```

Output: `app/build/outputs/bundle/release/app-release.aab`

Upload the `.aab` to [Google Play Console](https://play.google.com/console).

## Play Store checklist

- [ ] Privacy policy URL → https://github.com/haranilov/TouchNothing/blob/main/PRIVACY.md
- [ ] App icon and screenshots (portrait) → `store-assets/screenshots/phone/`
- [ ] Declare `READ_PHONE_STATE`: used only to end sessions on incoming cellular calls
- [ ] Content rating questionnaire
- [ ] Supabase production keys in `local.properties` before release build
- [ ] Run `./gradlew testDebugUnitTest lintDebug bundleRelease` before upload

## Project structure

- `app/` — Android application (Kotlin + Jetpack Compose)
- `supabase/` — database migrations
- `scripts/e2e-call-test.sh` — end-to-end call interruption test

## Permissions

- `INTERNET` — leaderboard and account sync
- `READ_PHONE_STATE` — end session on incoming cellular calls (optional; VoIP detected without it)

## Repositories

- `main` — Android app
- `ios` — iOS app (App Store)

## Privacy

Canonical policy (iOS + Android): https://github.com/haranilov/TouchNothing/blob/main/PRIVACY.md

Local copy: [PRIVACY.md](PRIVACY.md)
