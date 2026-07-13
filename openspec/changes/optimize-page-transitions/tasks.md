# Optimize Page Transitions Tasks

## 1. Planning and Safety
- [x] Confirm current git status and avoid overwriting unrelated uncommitted changes.
- [x] Keep every implementation diff small and reviewable.
- [x] Run targeted checks after each step.

## 2. Native History Loading
- [x] Add a Room projection for history preview rows.
- [x] Add a single-query DAO method for latest history previews.
- [x] Update `MainActivity.getLatestHistory()` to use the projection instead of per-row `getLatestRevision()`.
- [x] Preserve existing Pigeon DTO fields and behavior.

## 3. Room Indexes
- [x] Add indexes for common history sort/filter paths in `NotificationRecord`.
- [x] Add or verify indexes for latest revision lookup/sort in `NotificationRevision`.
- [x] Add the required Room migration for index creation.

## 4. Flutter Hot Build Paths
- [x] Remove synchronous icon path `existsSync()` from `DepthAppBadge.build()`.
- [x] Remove synchronous media `existsSync()` from History row build.
- [x] Remove synchronous media `existsSync()` from Detail revision card build.
- [x] Add bounded image decode hints for app icons and thumbnails where practical.

## 5. Lightweight Dense List Surfaces
- [x] Add a lightweight list card that preserves the NotTik depth look without full per-row own-layer glass.
- [x] Use the lightweight card in History rows.
- [x] Use the lightweight card in Apps rows.
- [x] Keep full Liquid Glass on shell/navigation/hero/settings surfaces.

## 6. Lazy History Tabs and Repaint Isolation
- [ ] Avoid building all filtered history lists before they are needed.
- [x] Add repaint isolation around static ambient background or expensive static layers.
- [x] Keep RTL tab styling unchanged: light selected black, dark selected white.

## 7. Verification
- [x] Run targeted `dart analyze` on changed Dart files.
- [x] Run `dart format --set-exit-if-changed .`.
- [x] Run `flutter analyze`.
- [x] Run `flutter test`.
- [ ] Run `cd android && ./gradlew lint test` without timeout. Current run timed out after 600s; app-scoped Gradle checks passed.
- [x] Verify final manifest has no `INTERNET` permission.
- [x] Document manual profile-mode verification on physical Android API 26+.
