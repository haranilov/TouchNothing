# TouchNothing Privacy Policy

**Last updated:** July 2, 2026  
**Contact:** https://github.com/haranilov/TouchNothing/issues

TouchNothing ("the App") is developed by Kos Haranilov. This policy applies to the iOS and Android versions of TouchNothing and explains what data the App collects and how it is used.

## Summary

TouchNothing collects a nickname and gameplay statistics to provide accounts, leaderboards, and personal totals. We do not sell your data, show ads, or use your data for tracking.

## Data We Collect

### Nickname (User ID)
- You choose a nickname when you create an account or use Guest mode.
- Used to identify your account, sign you in, and display your name on leaderboards.
- Stored on our backend (Supabase) and locally on your device.

### Gameplay data
- Session duration (seconds), best session, total time, and session count.
- Used for leaderboards, your profile ("My Total"), and app functionality.
- Stored on our backend and may be shown publicly on leaderboards with your nickname.

### PIN
- If you create an account, you set a 4-digit PIN.
- The PIN is **not stored in plain text**. Only a secure hash is stored on the server.
- The PIN is not shared with other users.

### Guest mode
- Guest accounts use an auto-generated nickname and PIN stored only on your device.
- If you delete the app or switch devices, guest progress may be lost.

### Local device storage
- The App stores your nickname, session token, and preferences (for example, whether rules were hidden) locally on your device.
- On **iOS**, this uses UserDefaults.
- On **Android**, this uses SharedPreferences.

### Session interruption (on-device)
- During an active session, the App ends your session when you touch the screen or when the App is no longer in the foreground (for example, switching apps or opening Control Center), as described in the in-app rules.
- On **iOS**, the App does not use CallKit or other call-detection APIs. It does not place calls or access your phone number.
- On **Android**, you may be asked to allow phone access (`READ_PHONE_STATE`). If granted, the App reads call state only to end your session on incoming cellular calls. The App does not place calls, record calls, or access your phone number. If you deny the permission, the App still works; some VoIP calls may still end a session when the system routes audio for a call.
- Session-interruption signals are processed on your device and are not uploaded to our servers.

## Data We Do Not Collect

- Name, email, phone number, or physical address (unless you contact us voluntarily)
- Precise location
- Contacts, photos, microphone, or camera data
- Advertising identifiers
- Payment information (the App has no in-app purchases)

## How Data Is Used

- To authenticate you and keep you signed in
- To save and display your scores and totals
- To operate global leaderboards
- To protect accounts (for example, limiting failed sign-in attempts)
- To end an active session when you touch the screen or leave the App (on-device only)
- On Android, to optionally end a session when an incoming cellular call is detected (on-device only)

## Third-Party Services

The App uses [Supabase](https://supabase.com) for backend hosting, authentication, and database storage. Data sent to Supabase is protected in transit using HTTPS.

Supabase privacy information: https://supabase.com/privacy

## Data Sharing

We do not sell your personal data. Leaderboard nicknames and session times are visible to other App users. We may disclose data if required by law.

## Data Retention

Account and gameplay data remain until you delete your account or we remove it. You can delete your account in the app from **My Total → Delete Account**.

## Children

TouchNothing is not directed at children under 13. We do not knowingly collect data from children under 13.

## Security

We use industry-standard measures including hashed PINs, session tokens, and HTTPS. No method of transmission or storage is 100% secure.

## Your Choices

- You may use Guest mode without creating a permanent account.
- You may sign out at any time from the app menu.
- On Android, you may deny phone permission and still use the App.
- You may delete your account and associated data in the app from **My Total → Delete Account**. Registered accounts require your PIN; guest accounts require confirmation only.

## Changes

We may update this policy. The "Last updated" date at the top will change when we do.

## Contact

Questions about this policy: https://github.com/haranilov/TouchNothing/issues
