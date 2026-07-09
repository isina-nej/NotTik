## ADDED Requirements

### Requirement: Implementation
- Must use Android WorkManager for periodic cleanup.

### Requirement: Policies
- Must support global retention periods (e.g., 7 days, 30 days, never).
- Must support per-app retention overrides.
- Work must be cancelled if cleanup is disabled in settings.

#### Scenario: WorkManager cleanup
- Given retention is 7 days
- Then WorkManager purges 8 day old data
