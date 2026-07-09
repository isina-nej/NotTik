# 1. Native Room as Source of Truth

Date: 2026-07-09

## Status
Accepted

## Context
NotTik needs to capture Android notifications via `NotificationListenerService` reliably, even when the user has swiped the app away and the Flutter UI is completely destroyed. If we relied on Flutter-side SQLite (like Drift) being the single writer, we would have to boot the Flutter engine in the background for every incoming notification, which is expensive, slow, and prone to being killed by the OS.

## Decision
We will use Kotlin and Android Room as the native persistence layer and the single source of truth.
The `NotificationListenerService` will parse the incoming `StatusBarNotification` and write directly to Room via Kotlin Coroutines. 

## Consequences
- **Positive:** Maximum reliability for notification capture. No Flutter overhead in the background.
- **Negative:** We must write a bridge (Pigeon) to allow Flutter to query this native Room database for the UI.
