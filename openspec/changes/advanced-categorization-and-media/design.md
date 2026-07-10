# Design: Advanced Categorization and Media Storage

## High-Level Architecture
1. **Native Listener**: `NottikNotificationListener.kt` detects incoming media (Bitmaps from `EXTRA_PICTURE` or `EXTRA_LARGE_ICON`). It saves the Bitmap to a secure local folder (`/data/data/com.nottik.app/files/media/`) using a UUID-based filename.
2. **Room Database**: The path to this file is saved as a new string column `mediaPath` in the `NotificationRevision` table. We also extract `senderName` from `EXTRA_MESSAGES` and save it to the `NotificationRecord` table.
3. **Pigeon Bridge**: `getLatestHistory` is expanded or a new method `getFilteredHistory(type, filterId)` is created to return records based on "App" or "Sender".
4. **Flutter UI**: 
   - `HistoryScreen` uses a `TabBar` (All / By App / By Person) to let users toggle views.
   - `DetailScreen` uses `Image.file()` to render the stored `mediaPath` if it exists.

## Constraints
- **Privacy First**: All media MUST be saved to app-internal storage. No `READ_EXTERNAL_STORAGE` or `INTERNET` permissions can be added.
- **Performance**: Bitmaps must be compressed and saved asynchronously (via `suspend` IO dispatchers) so the Listener thread is not blocked. Cleanup Worker must also delete these media files when retaining records older than the limit.