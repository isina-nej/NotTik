# Media Storage Specification

## Purpose
Store notification icons and attached images locally.

## Explicit Requirements
- Must save files in app-private internal storage (`Context.filesDir`).
- Must compress and resize large bitmaps before saving.
- Must deduplicate based on content hashing if possible.
- Must clean up orphaned files when the database record is deleted.

## Out-of-scope
- Saving to the public Gallery automatically.
