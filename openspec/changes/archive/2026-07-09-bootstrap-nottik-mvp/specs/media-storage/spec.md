## ADDED Requirements

### Requirement: Storage Location
- Must save files in app-private internal storage (`Context.filesDir`).

### Requirement: Processing
- Must compress and resize large bitmaps before saving.
- Must deduplicate based on content hashing if possible.

### Requirement: Cleanup
- Must clean up orphaned files when the database record is deleted.

#### Scenario: Image capture
- Given an image notification
- Then media is scaled and saved privately
