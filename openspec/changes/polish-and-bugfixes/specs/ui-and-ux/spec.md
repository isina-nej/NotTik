# UI and UX Specification

## 1. Vazirmatn Font Integration
**Goal:** Correctly render the Persian UI.
**Actions:**
- Download Vazirmatn font (Regular, Medium, Bold).
- Place in `assets/fonts/Vazirmatn/`.
- Register in `pubspec.yaml` under `flutter -> fonts`.
- Confirm `AppTheme.dart` matches the family name.

## 2. True Glassmorphism
**Goal:** Add the missing blur effect.
**Actions:**
- Update `GlassmorphismCard` in `app_theme.dart`.
- Wrap the container with `ClipRRect` and `BackdropFilter` using `ImageFilter.blur`.

## 3. Pagination UX Fix
**Goal:** Seamless infinite scrolling.
**Actions:**
- Update `history_provider.dart -> loadMore`.
- Instead of setting state to `AsyncLoading()`, emit an `AsyncData` state with a boolean flag indicating loading, or use Riverpod's built-in `isLoading` while preserving previous data (e.g., `state = const AsyncValue.loading().copyWithPrevious(state)`).
- Fix `hasMore` logic in `MainActivity.kt` to handle exact multiples of the limit correctly.

## 4. Settings Dialogs
**Goal:** Make the settings fully interactive.
**Actions:**
- Implement `showLanguageDialog` utilizing `appLocaleProvider`.
- Implement `showThemeDialog` utilizing `appThemeModeProvider`.
- Implement `showRetentionDialog` (mock UI for now, or connect to Pigeon if native API exists).