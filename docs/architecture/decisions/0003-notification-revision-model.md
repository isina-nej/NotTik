# 3. Notification Revision Model

Date: 2026-07-09

## Status
Accepted

## Context
Apps frequently update the same notification (e.g., download progress, or appending new messages to a chat). Android issues a new `onNotificationPosted` with the same key.

## Decision
We will use a Parent-Child (Revision) model in the database.
- `NotificationRecord`: Represents the logical notification (identified by key/tag/id).
- `NotificationRevision`: Represents each distinct state.
When an update arrives, we will hash the content. If the hash matches the latest revision, we ignore it (deduplication). If it differs, we insert a new `NotificationRevision`.

## Consequences
- **Positive:** We retain a complete history of changes without destroying old data, and we don't spam the DB with identical duplicate callbacks.
- **Negative:** Requires slightly more complex SQL joins when querying the latest state for the UI.
