# 7. WorkManager Retention Cleanup

Date: 2026-07-09

## Status
Accepted

## Context
Without cleanup, NotTik will eventually fill the user's storage.

## Decision
We will use Android `WorkManager` to schedule a periodic job (e.g., daily) that queries the DB for notifications older than the user's retention setting, deletes them, and deletes their associated media files.

## Consequences
- **Positive:** Reliable background execution.
- **Negative:** We have to expose settings for this via Flutter and pipe them down to configure the WorkManager natively.
