# NotTik

NotTik is an Android-only notification history app built for privacy-first, fully local use. It saves notification text, revisions, app icons, and supported notification media into local device storage so users can review what Android exposed to the notification listener.

> NotTik has no `INTERNET` permission, no backend, no telemetry, and no analytics SDK.

## Highlights

- Fully offline Android app.
- Persian-first RTL interface with English support.
- Native Kotlin `NotificationListenerService` for capture.
- Native Room database as the source of truth.
- Typed Flutter ↔ Kotlin bridge generated with Pigeon.
- Flutter UI with Riverpod, go_router, Material 3, and Liquid Glass-inspired depth.
- Local export, backup, retention cleanup, and offline log sharing.

## Honest limits

NotTik only stores notifications that Android exposes while Notification Access is enabled.

It cannot:

- recover notifications from before installation or before permission was granted;
- recover deleted messages that were never captured;
- bypass Android OTP redaction or secure lock-screen redactions;
- download full chat history or remote media from other apps.

## Privacy model

NotTik is designed so network exfiltration is physically blocked at the Android manifest level.

- No `android.permission.INTERNET`.
- No remote server.
- No crash analytics.
- No third-party telemetry.
- Notification data is stored in local SQLite/Room and app-internal files.

See also: [`docs/privacy.md`](docs/privacy.md).

## Platform support

- Android only.
- Minimum SDK: 26.
- Requires Notification Access permission.

## Architecture

```text
Android NotificationListenerService
        ↓
Native Kotlin capture pipeline
        ↓
Room database + internal files
        ↓
Pigeon typed bridge
        ↓
Flutter UI: Riverpod + go_router + gen_l10n
```

Important project rules:

- Native Room DB is the source of truth.
- Flutter does not own persistent notification data.
- Pigeon is used instead of raw MethodChannel.
- The app must remain local-only.

## Repository layout

```text
android/                         Native Android, Room, service, signing config
lib/app/                         Flutter app code
lib/app/bridge/                  Generated Pigeon Dart bridge
lib/app/data/providers/          Riverpod providers
lib/app/routing/                 go_router setup
lib/app/ui/screens/              App screens
lib/app/ui/theme/                NotTik visual system
lib/l10n/                        ARB files and generated localizations
pigeons/messages.dart            Pigeon schema source
docs/                            Architecture, privacy, release notes
openspec/                        Feature/change specifications
```

## Development setup

Prerequisites:

- Flutter SDK.
- Android SDK and emulator/device.
- JDK 17.
- Android Notification Access for runtime testing.

Recommended commands:

```bash
flutter pub get
dart run build_runner build -d
flutter gen-l10n
```

## Run locally

```bash
flutter run -d emulator-5554
```

If `flutter install` looks for a release APK after a debug build, install the debug APK directly:

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.nottik.app/.MainActivity
```

## Quality gates

Run before merging or releasing:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
cd android && ./gradlew :app:lintDebug :app:testDebugUnitTest :app:assembleDebug
```

Privacy gate:

```bash
grep -R "android.permission.INTERNET" android/app/src/main || true
```

Expected: no output.

## Release build

Release builds require a local upload keystore. The release build must never fall back to debug signing.

1. Copy the template:

   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Create or place your upload keystore at:

   ```text
   android/app/upload-keystore.jks
   ```

3. Fill `android/key.properties`.

4. Build the Play artifact:

   ```bash
   cd android && ./gradlew :app:bundleRelease
   ```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Full checklist: [`docs/release.md`](docs/release.md).

## Links

- Website: <https://nottik.app>
- GitHub: <https://github.com/isina-nej/NotTik>

## License

License is not declared yet. Add a `LICENSE` file before public distribution if needed.
