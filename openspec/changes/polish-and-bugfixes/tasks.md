# Polish and Bugfixes - Task List

## 1. Cleanup and Refactor
- [ ] Delete `android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt`.
- [ ] Delete `lib/core/platform/messages.g.dart`.
- [ ] Update `AppMetadataDao.kt` to use `suspend` for all methods.
- [ ] Update `MainActivity.kt` to handle the suspended `AppMetadataDao` methods.
- [ ] Refactor `ExportUtils.kt` to include full notification fields and revisions.
- [ ] Remove `fallbackToDestructiveMigration` from `AppDatabase.kt`.

## 2. Localization
- [ ] Extract all hardcoded strings from `history_screen.dart` to ARB files.
- [ ] Extract all hardcoded strings from `apps_screen.dart` to ARB files.
- [ ] Extract all hardcoded strings from `settings_screen.dart` to ARB files.
- [ ] Run `flutter gen-l10n`.
- [ ] Update the UI files to use `AppLocalizations`.

## 3. UI and UX
- [ ] Download Vazirmatn font files and add to `assets/fonts/Vazirmatn`.
- [ ] Update `pubspec.yaml` to register Vazirmatn.
- [ ] Refactor `GlassmorphismCard` in `app_theme.dart` to use `BackdropFilter` and `ClipRRect`.
- [ ] Fix pagination `loadMore` in `history_provider.dart` to avoid `AsyncLoading` flash (use `.copyWithPrevious`).
- [ ] Fix pagination `hasMore` logic in `MainActivity.kt`.
- [ ] Implement `showLanguageDialog` in `settings_screen.dart`.
- [ ] Implement `showThemeDialog` in `settings_screen.dart`.

## 4. Verification
- [ ] Run `flutter analyze` and ensure zero warnings.
- [ ] Run `flutter test`.
- [ ] Build and run the Android app to verify font rendering, blur effect, and pagination.
- [ ] Export JSON and verify the payload contains title, text, and revisions.