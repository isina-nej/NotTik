# export-backup-restore Specification

## Purpose
TBD - created by archiving change bootstrap-nottik-mvp. Update Purpose after archive.
## Requirements
### Requirement: Export
- Must export text data to JSON and CSV.

### Requirement: Backup Archive
- Must create a full local backup archive (ZIP) containing the SQLite DB and media files.
- Must support restoring from a valid backup archive.

### Requirement: SAF
- Must use the Storage Access Framework (SAF) to let the user choose where to save the files.

#### Scenario: Backup data
- Given user requests backup
- Then SAF prompt opens and ZIP is saved

