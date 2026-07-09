# Retention and Cleanup Specification

## Purpose
Prevent the application from consuming all device storage over time.

## Explicit Requirements
- Must use Android WorkManager for periodic cleanup.
- Must support global retention periods (e.g., 7 days, 30 days, never).
- Must support per-app retention overrides.
- Work must be cancelled if cleanup is disabled in settings.

## Out-of-scope
- Cloud offloading of old notifications.
