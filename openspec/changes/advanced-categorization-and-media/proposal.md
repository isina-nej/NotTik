# Proposal: Advanced Categorization and Media Storage

## Why
The current notification capture is basic: it records text and app name but loses media (images/icons) attached to the notifications. Additionally, users can only view notifications in a flat list. To provide a superior archiving experience, NotTik needs advanced categorization (filtering by app and sender/person) and full media retention (saving attached images locally) so users can view the entire context of a notification, even if deleted from the source app.

## What Changes
1. **Media Storage (Kotlin/Room)**:
   - Extract `EXTRA_PICTURE`, `EXTRA_LARGE_ICON`, and other media URIs from `MessagingStyle` in `NottikNotificationListener.kt`.
   - Save bitmaps to internal `Context.filesDir` (to maintain the strict local-only privacy rule, avoiding external storage).
   - Update Room Database models (`NotificationRecord`/`NotificationRevision`) to include a `mediaPath` column.
2. **Advanced Categorization (Kotlin/Flutter)**:
   - Extract sender names from `EXTRA_CONVERSATION_TITLE` and `EXTRA_MESSAGES`.
   - Update Pigeon bridge to support queries filtering by `packageName` and `senderName`.
   - Update Flutter UI (`HistoryScreen` and `AppsScreen`) to include Tabs/Filters for "All", "Apps", and "People".
3. **Detail View Enhancement (Flutter)**:
   - Update `DetailScreen` to display the extracted media files (images) alongside the full notification text.