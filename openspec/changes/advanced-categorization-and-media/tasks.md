# Tasks: Advanced Categorization and Media Storage

- [x] 1. Update `NotificationRecord` entity to add `senderName: String?`.
- [x] 2. Update `NotificationRevision` entity to add `mediaPath: String?`.
- [x] 3. Write a Room Database Migration strategy from version 1 to version 2 to add these columns.
- [x] 4. Update `NottikNotificationListener.kt` to extract Bitmaps from `EXTRA_PICTURE`/`EXTRA_LARGE_ICON`.
- [x] 5. Update `NottikNotificationListener.kt` to extract `senderName` from `EXTRA_MESSAGES` or `EXTRA_TITLE`.
- [x] 6. Implement a secure file saver function in Kotlin to write Bitmaps to `Context.filesDir/media` and return the relative path.
- [x] 7. Update Pigeon schemas (`NativeNotificationRecord` and `NativeNotificationRevision`) to include `senderName` and `mediaPath`.
- [x] 8. Run `pigeon` generator to update Dart/Kotlin bridge files.
- [x] 9. Update `CleanupWorker.kt` to delete the associated media files when a record is dropped from the database.
- [x] 10. Update Flutter `HistoryScreen` to include a TabBar (All, Apps, People) and filter logic.
- [x] 11. Update Flutter `DetailScreen` to display the image using `Image.file()` if `mediaPath` is not null.
- [x] 12. Run `flutter analyze` and `flutter test`.
- [x] 13. Run `./gradlew assembleDebug` to verify Kotlin compilation.