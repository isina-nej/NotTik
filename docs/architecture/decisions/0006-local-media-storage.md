# 6. Local Media Storage

Date: 2026-07-09

## Status
Accepted

## Context
Notifications often contain large bitmaps (BigPictureStyle) or icons. Storing these directly in the SQLite database as BLOBs degrades DB performance significantly.

## Decision
We will extract Bitmaps from the `Notification.extras`, compress them (e.g., JPEG/WEBP), and save them to `Context.filesDir` (app-private internal storage). The database will only store the relative file path.

## Consequences
- **Positive:** Keeps the DB lean and fast.
- **Negative:** We must implement careful cleanup logic to delete files when their corresponding DB records are deleted, to avoid leaking storage.
