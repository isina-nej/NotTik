# NotTik

NotTik is a fully offline, privacy-respecting Android application that archives your notifications locally. It has no internet permission, no backend, and no analytics.

## Prerequisites
- Android device or emulator running API 26 (Android 8.0) or higher.
- Notification Access must be explicitly granted to the app.

## Build Instructions
1. `flutter pub get`
2. `dart run build_runner build -d`
3. `cd android && ./gradlew assembleDebug`
4. The APK will be available in `build/app/outputs/flutter-apk/app-debug.apk`

## Architecture
- **Backend:** Native Kotlin `NotificationListenerService` capturing notifications directly to a Room DB.
- **Frontend:** Flutter UI communicating with the Room DB via Pigeon generated channels.
- **Design:** Material 3 with Riverpod for state management.

## Limitations
- It cannot recover notifications that were missed before the app was installed or before permission was granted.
- Android OS features (like Doze or aggressive battery optimization on certain OEMs) might occasionally kill the listener process.
- By design, it does not bypass OTP redaction or secure lock screen redactions.

## Localization
Persian (Farsi) will be the default language, with full English support.
