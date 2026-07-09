# Design: NotTik MVP

## Architecture Overview

NotTik is a hybrid application featuring a robust native Kotlin backend for data capture and a Flutter frontend for presentation.

### Container / Component Architecture

1.  **Notification Capture Service (Kotlin):** Extends `NotificationListenerService`. Runs independently of Flutter. Listens to OS broadcasts.
2.  **Native Persistence Layer (Kotlin / Room):** The single source of truth. Handles database transactions and schema migrations.
3.  **Background Jobs (Kotlin / WorkManager):** Periodically prunes old notifications based on retention policies.
4.  **Native Bridge (Pigeon):** Generates type-safe data transfer objects (DTOs) and APIs for Flutter to read the Room DB and for Kotlin to send real-time updates.
5.  **Presentation Layer (Flutter):** Provides the UI. Built with Riverpod (state) and go_router (navigation).

### Persistence Model

-   **Database:** SQLite via Room.
-   **Concurrency:** WAL (Write-Ahead Logging) enabled. All Kotlin writes happen off the main thread using Coroutines. Flutter reads happen asynchronously via Pigeon.
-   **Media Storage:** Icons and large images are extracted from the `Notification` bundle and saved to app-private internal storage (`Context.getFilesDir()`). The DB stores relative file paths.

### Privacy & Permissions

-   **No INTERNET Permission:** The final AndroidManifest will not contain `<uses-permission android:name="android.permission.INTERNET" />`.
-   **Package Visibility:** We avoid `QUERY_ALL_PACKAGES`. We query launcher intents for an initial list and discover other apps passively as notifications arrive.

### Localization & Theme

-   **gen_l10n:** Standard Flutter localization.
-   **Themes:** Custom Semantic Material 3 themes (Light/Dark) implementing the "soft glass" / premium requirement.
