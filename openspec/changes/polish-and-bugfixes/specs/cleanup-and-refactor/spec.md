# Cleanup and Refactor Specification

## 1. Pigeon Bridge Cleanup
**Goal:** Remove legacy/dead generated code and ensure a single source of truth.
**Actions:**
- Delete `android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt`
- Delete `lib/core/platform/messages.g.dart`
- Ensure `Pigeon.kt` and `pigeon.dart` are the only active generated files.

## 2. AppMetadataDao Coroutines
**Goal:** Prevent IO blocking and Room warnings.
**Actions:**
- Update `AppMetadataDao.kt` methods to be `suspend` functions:
  - `getAllAppMetadata()`
  - `getAppMetadata()`
  - `insertAppMetadata()`
  - `updateLoggingStatus()`
- Verify `MainActivity.kt` coroutine contexts still compile correctly.

## 3. JSON Export Fix
**Goal:** Export full notification data.
**Actions:**
- Update `ExportUtils.kt -> exportToJson`.
- Fetch revisions alongside records.
- JSON structure should include: `package`, `app_name`, `post_time`, `title`, `text`, `big_text`, `revisions` array.

## 4. Room Database Stability
**Goal:** Prevent accidental data loss.
**Actions:**
- Remove `.fallbackToDestructiveMigration()` from `AppDatabase.kt`.
- Prepare for standard schema migrations in future updates.