# Prepare Play Release Tasks

## 1. Planning
- [x] Inspect current git status, README, Android signing, routes, l10n, and cleanup candidates.
- [x] Avoid broad ignored-file cleanup because Gradle wrapper is currently ignored.

## 2. Signing
- [x] Fix Android release signing to use local upload keystore properties.
- [x] Add `android/key.properties.example`.
- [x] Ensure keystore and `key.properties` stay ignored.
- [x] Generate a local upload keystore if missing.

## 3. About Page
- [x] Add localized About strings.
- [x] Add `AboutScreen`.
- [x] Add `/about` route.
- [x] Add Settings entry.
- [x] Open website and GitHub links safely.

## 4. Documentation
- [x] Rewrite `README.md`.
- [x] Add `docs/release.md`.

## 5. Cleanup
- [x] Remove explicit disposable caches: `build/`, `.dart_tool/`, `android/.gradle/`, `node_modules/`.
- [x] Preserve Gradle wrapper files.

## 6. Verification
- [x] `flutter pub get`.
- [x] `dart run build_runner build -d` if generated files need refresh.
- [x] `flutter gen-l10n`.
- [x] `dart format --set-exit-if-changed .`.
- [x] `flutter analyze`.
- [x] `flutter test`.
- [x] Android release lint/test/build.
- [x] Verify manifest has no `android.permission.INTERNET`.
- [x] Install/launch debug build on emulator after cleanup.
