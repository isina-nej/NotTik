# NotTik Release Checklist

NotTik is Android-only and fully local. A release build must preserve the no-network privacy model and must be signed with a private upload key.

## 1. Keystore

Create a local upload keystore if it does not exist:

```bash
keytool -genkeypair \
  -v \
  -storetype JKS \
  -keystore android/app/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Then copy the template:

```bash
cp android/key.properties.example android/key.properties
```

Fill the local passwords in `android/key.properties`.

Never commit:

```text
android/key.properties
android/app/*.jks
android/app/*.keystore
```

## 2. Privacy gate

Before every release, verify the final Android manifest and source manifest do not declare internet permission:

```bash
grep -R "android.permission.INTERNET" android/app/src/main || true
```

Expected: no output.

## 3. Quality gates

Run:

```bash
flutter pub get
dart run build_runner build -d
flutter gen-l10n
dart format --set-exit-if-changed .
flutter analyze
flutter test
cd android && ./gradlew :app:lintRelease :app:testDebugUnitTest :app:bundleRelease
```

## 4. Play artifact

Upload this file to Google Play Console:

```text
build/app/outputs/bundle/release/app-release.aab
```

## 5. Honest store copy

Do not claim NotTik can recover deleted or never-captured notifications. It only stores notifications that Android exposes while Notification Access is enabled, and it does not bypass OTP or secure redactions.
