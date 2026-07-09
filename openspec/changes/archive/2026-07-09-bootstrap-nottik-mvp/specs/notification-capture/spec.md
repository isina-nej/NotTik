## ADDED Requirements

### Requirement: Native Capture
- Must use `NotificationListenerService` in Kotlin.
- Must capture `onNotificationPosted` and `onNotificationRemoved`.
- Must run even if `MainActivity` is destroyed.

### Requirement: Safe Extraction
- Must safely extract text, bundles, and media without crashing on malformed parcels.

### Requirement: Revision Handling
- Must create a new revision only when meaningful content changes.

#### Scenario: Notification is captured
- Given a notification is posted
- Then NotTik extracts and saves it to the local Room database
