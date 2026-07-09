# Proposal: Bootstrap NotTik MVP

## Why
Users need a reliable, privacy-respecting way to archive their Android notifications without relying on cloud services, external servers, or apps packed with trackers. Native Android history is limited, ephemeral, and often difficult to search.

## What Changes
Create a fully offline Flutter/Android application, **NotTik**, that captures notifications via `NotificationListenerService`, stores them locally using Room DB, and provides a beautiful, searchable, RTL-friendly Flutter interface.

## Scope

- Android API 26+ target.
- Fully local operation (no `INTERNET` permission).
- Native Kotlin `NotificationListenerService`.
- Native Room Database as the source of truth.
- Pigeon for native-to-Flutter bridging.
- Flutter UI using Material 3 and Riverpod.
- Persian (default RTL) and English (LTR) support.
- Configurable retention and local cleanup via WorkManager.
- Export and local backup capabilities.
