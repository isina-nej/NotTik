# Export, Backup, and Restore Specification

## Purpose
Allow users to own their data and move it to a new device.

## Explicit Requirements
- Must export text data to JSON and CSV.
- Must create a full local backup archive (ZIP) containing the SQLite DB and media files.
- Must support restoring from a valid backup archive.
- Must use the Storage Access Framework (SAF) to let the user choose where to save the files.

## Out-of-scope
- Automatic Google Drive backup integration (requires network).
