# Optimize Page Transitions Implementation Plan

> **For Hermes:** Implement this plan task-by-task with explicit user approval before production code changes.

**Goal:** Reduce NotTik page-transition and dense-list jank without removing the Liquid Glass identity.

**Architecture:** Fix native data loading first, then remove Flutter hot-path blocking work, then lighten dense list rendering. Keep Pigeon, Room, offline-only privacy, Persian RTL, and current visual direction intact.

**Tech Stack:** Flutter, Riverpod, go_router, Pigeon, Kotlin, Room, Android.

---

## Current Context

- Workspace: `/home/sina/orca/projects/NotTik`
- Flutter binary: `/home/sina/develop/flutter/bin/flutter`
- Targeted Dart analysis currently passes for the inspected UI/provider files.
- `openspec` CLI was not found in `PATH`; OpenSpec files are written directly using the existing project layout.
- The repository has many uncommitted changes. Avoid broad rewrites and destructive edits.

## Evidence

- `MainActivity.getLatestHistory()` maps records and calls `getLatestRevision(record.id)` per row.
- `NotificationRecord` has no entity-level indexes for `last_update_time`, `is_group_summary`, `package_name`, or `custom_category`.
- `DepthAppBadge.build()` calls `File(path).existsSync()`.
- History and Detail media checks call `File(mediaPath).existsSync()` in build paths.
- `GlassmorphismCard` uses `GlassCard(useOwnLayer: true)` and is used for dense list rows.

---

## Task 1: Native history preview projection

**Objective:** Remove the N+1 latest-revision query pattern from initial history loading.

**Files:**
- Modify: `android/app/src/main/kotlin/com/nottik/app/db/NotificationDao.kt`
- Modify: `android/app/src/main/kotlin/com/nottik/app/MainActivity.kt`

**Steps:**
1. Add a DAO projection data class for a history preview row.
2. Add a query that joins each record to its latest revision in one query.
3. Replace per-row `getLatestRevision(record.id)` calls in `MainActivity.getLatestHistory()`.
4. Preserve `NativeNotificationRecord` output fields.
5. Run Kotlin/Android checks after the native diff.

**Verification:**

```bash
cd android && ./gradlew lint test
```

If Gradle infrastructure blocks, document the exact blocker and run narrower syntax/build checks available locally.

---

## Task 2: Room indexes and migration

**Objective:** Speed common history sort/filter paths.

**Files:**
- Modify: `android/app/src/main/kotlin/com/nottik/app/models/NotificationRecord.kt`
- Modify: `android/app/src/main/kotlin/com/nottik/app/models/NotificationRevision.kt`
- Modify: `android/app/src/main/kotlin/com/nottik/app/db/AppDatabase.kt`

**Steps:**
1. Add entity indexes for history sort/filter columns.
2. Add or verify revision indexes for latest revision lookup by parent and timestamp.
3. Increase Room database version.
4. Add migration that creates indexes for existing installs.
5. Keep migration non-destructive.

**Verification:**

```bash
cd android && ./gradlew lint test
```

---

## Task 3: Remove synchronous file checks from Flutter list builds

**Objective:** Stop list rows from blocking build on filesystem checks.

**Files:**
- Modify: `lib/app/ui/theme/app_theme.dart`
- Modify: `lib/app/ui/screens/history_screen.dart`
- Modify: `lib/app/ui/screens/detail_screen.dart`

**Steps:**
1. Change `DepthAppBadge` to attempt `Image.file` when path is non-empty and use `errorBuilder` fallback.
2. Remove `_HistoryTile._hasMedia()` filesystem check; use non-empty `mediaPath` for badge presence or move check out of build if necessary.
3. Remove revision-card `existsSync()` check; let `Image.file` handle error fallback.
4. Add `cacheWidth`/`cacheHeight` for small app icons where practical.
5. Run targeted Dart analysis.

**Verification:**

```bash
/home/sina/develop/flutter/bin/dart analyze lib/app/ui/theme/app_theme.dart lib/app/ui/screens/history_screen.dart lib/app/ui/screens/detail_screen.dart
```

---

## Task 4: Lightweight dense list card

**Objective:** Preserve visual depth while removing full own-layer glass from every dense row.

**Files:**
- Modify: `lib/app/ui/theme/app_theme.dart`
- Modify: `lib/app/ui/screens/history_screen.dart`
- Modify: `lib/app/ui/screens/apps_screen.dart`

**Steps:**
1. Add a small `DepthListCard` or equivalent lightweight card.
2. Use it for History rows.
3. Use it for Apps rows.
4. Leave `GlassmorphismCard` untouched for settings, hero cards, and shell chrome.
5. Run targeted Dart analysis.

**Verification:**

```bash
/home/sina/develop/flutter/bin/dart analyze lib/app/ui/theme/app_theme.dart lib/app/ui/screens/history_screen.dart lib/app/ui/screens/apps_screen.dart
```

---

## Task 5: Lazy history tabs and repaint isolation

**Objective:** Reduce page-entry work and isolate static expensive paint.

**Files:**
- Modify: `lib/app/ui/screens/history_screen.dart`
- Modify: `lib/app/ui/screens/shell_scaffold.dart`
- Possibly modify: `lib/app/ui/theme/app_theme.dart`

**Steps:**
1. Avoid doing all filter work for all tabs before needed.
2. Add `RepaintBoundary` around `AppAmbientBackground` in the shell.
3. Keep selected tab colors unchanged.
4. Run targeted Dart analysis.

**Verification:**

```bash
/home/sina/develop/flutter/bin/dart analyze lib/app/ui/screens/history_screen.dart lib/app/ui/screens/shell_scaffold.dart lib/app/ui/theme/app_theme.dart
```

---

## Task 6: Full verification

**Objective:** Prove the result is stable.

**Commands:**

```bash
dart format --set-exit-if-changed .
/home/sina/develop/flutter/bin/flutter analyze
/home/sina/develop/flutter/bin/flutter test
cd android && ./gradlew lint test
grep -R "android.permission.INTERNET" -n android/app/src/main AndroidManifest.xml || true
```

**Manual check:**

```bash
/home/sina/develop/flutter/bin/flutter run --profile
```

On a physical Android API 26+ device, inspect:
- History open
- History tab switch
- Apps open
- Detail open/back
- History scroll

---

## Risks

- Room migration must be exact and non-destructive.
- A single SQL join for latest revision must preserve current preview semantics.
- Removing file existence checks changes fallback timing from build-time to image-load-time.
- Visual changes must not drift away from NotTik Liquid Glass preference.

## Lazy alternative

Only fix the N+1 query and filesystem checks first. Skip card redesign until profiling proves the UI layer is still slow.
