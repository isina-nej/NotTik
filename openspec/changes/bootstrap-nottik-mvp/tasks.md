# Implementation Tasks

## Phase 4: Project Foundation
- [x] Initialize standard Flutter project structure.
- [x] Configure Android build (minSdk 26, package name `com.nottik.app`, namespace `com.nottik.app`).
- [x] Create AGENTS.md with autonomous agent guidelines.
- [x] Document Architecture Decision Records (ADRs).
- [x] Write initial research log.

## Phase 4b: Native Room Database
- [x] Implement AppDatabase, NotificationRecord entity, NotificationRevision entity, NotificationDao in Kotlin.
- [x] Add all required fields to NotificationRecord (appName, appNameEn, groupKey, channelId, priority, visibility, ongoing, clearable, isGroupSummary, lastUpdateTime, mediaPath, customCategory).
- [x] Add all required fields to NotificationRevision (subText, bigText, summaryText, infoText, textLines, conversationTitle, messagingMessages, progressMax, progressValue, progressIndeterminate, largeIconPath, bigPicturePath, appIconPath).
- [x] Add AppMetadata entity with per-app retention settings.
- [x] Add foreign keys and cascade behavior.
- [x] Add indexed stable identity (unique constraint on packageName+notificationId+tag).
- [x] Add Room schema export configuration.
- [x] Add explicit migration policy (fallbackToDestructiveMigration for MVP).
- [x] Add paginated latest-history query (JOIN records+revisions, ORDER BY postTime DESC, LIMIT/OFFSET).
- [x] Add notification-detail query (record + all revisions).
- [x] Add revision-list query.
- [x] Add removal update transaction (update record + set removalReason + removalTime).
- [x] Verify Room compiles via KSP.

## Phase 4c: Pigeon Bridge
- [x] Define initial Pigeon schema (isListenerConnected, requestRebind, openNotificationSettings).
- [x] Add paginated history API (offset, limit, optional filters).
- [x] Add notification detail API.
- [x] Add revision list API.
- [x] Add removal handling API.
- [x] Add app metadata query API.
- [x] Add filter configuration API.
- [x] Regenerate Pigeon Dart and Kotlin files.

## Phase 4d: NotificationListenerService
- [x] Basic onNotificationPosted and onNotificationRemoved skeleton.
- [x] Extract all required fields safely with per-field try-catch.
- [x] Handle MessagingStyle messages.
- [x] Handle grouped notifications (groupKey, group summary).
- [x] Extract largeIcon, bigPicture, appIcon bitmaps and save to internal storage.
- [x] Implement semantic content hashing (all text fields, not just title+text).
- [x] Implement duplicate revision prevention with hash comparison.
- [x] Handle onNotificationRemoved (update removalTime and removalReason).
- [x] Add lifecycle cancellation for CoroutineScope (override onDestroy).
- [x] Remove sensitive Log.d/Log.e calls (only log package name in debug).
- [x] Add listener connection diagnostics.

## Phase 4e: Build Fix
- [x] Fix Gradle build: resolve KSP plugin version compatibility.
- [x] Verify KSP runs successfully for Room compiler.
- [x] Verify `flutter analyze` passes.
- [x] Verify Kotlin compilation passes.
- [x] Verify minimal Debug APK builds.
- [x] Create Git checkpoint after successful build.

## Phase 5: Flutter UI — Vertical Slice
- [x] Set up gen_l10n for Persian (default) and English.
- [x] Implement complete theme system (Light/Dark/System, semantic colors).
- [x] Build Onboarding screen with localized strings and RTL support.
- [x] Build History list with pagination/infinite scroll.
- [x] Build Notification Detail screen with revision history.
- [x] Build loading, empty, and error states for all screens.
- [x] Ensure all user-facing strings come from localization files.
- [x] Ensure Persian is default, RTL works; English LTR works.

## Phase 6: Remaining Features
- [x] Implement application filtering logic (Mode A / Mode B).
- [x] Build App Management / Filtering UI.
- [x] Implement Category assignment and Search logic + UI.
- [ ] Implement Favorites.
- [x] Build Settings screen (retention policy, theme, language).
- [x] Implement WorkManager background cleanup.
- [x] Implement Export (JSON/CSV) using SAF.
- [x] Implement Backup (ZIP archive) and Restore.
- [ ] Build Statistics view.
- [ ] Build Diagnostics view.

## Phase 7: Testing
- [x] Kotlin unit tests: stable identity, hashing, duplicate revision suppression, null extras, malformed fields, Room insert/query, pagination, record/revision relationship.
- [x] Flutter widget tests: Persian default, RTL, LTR, empty history, populated history, loading, error, detail screen.
- [x] Verify `dart format --set-exit-if-changed .` passes.
- [x] Verify `flutter analyze` passes.
- [x] Verify `flutter test` passes.
- [ ] Verify `./gradlew lint` passes.
- [ ] Verify `./gradlew test` passes.

## Phase 8: Delivery
- [ ] Verify merged manifest has no `android.permission.INTERNET`.
- [ ] Verify no analytics, Firebase, crash reporting, ad SDKs, AccessibilityService, or QUERY_ALL_PACKAGES.
- [ ] Verify Debug APK builds and its path exists.
- [ ] Document privacy verification result.
- [ ] Honest progress report in Persian.