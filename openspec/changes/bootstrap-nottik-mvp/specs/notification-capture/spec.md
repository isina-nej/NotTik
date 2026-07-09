# Notification Capture Specification

## Purpose
Reliably capture Android notifications in the background, independently of the Flutter UI.

## Explicit Requirements
- Must use `NotificationListenerService` in Kotlin.
- Must capture `onNotificationPosted` and `onNotificationRemoved`.
- Must run even if `MainActivity` is destroyed.
- Must safely extract text, bundles, and media without crashing on malformed parcels.
- Must create a new revision only when meaningful content changes.

## Out-of-scope
- Reading historical notifications prior to installation.
- Bypassing OTP redaction or secure lock screen redaction manually.
