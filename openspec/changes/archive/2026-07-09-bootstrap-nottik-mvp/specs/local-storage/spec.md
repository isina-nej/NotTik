## ADDED Requirements

### Requirement: Database
- Must use Room Database.
- Must implement explicit schema migrations.

### Requirement: Threading
- Must not perform DB I/O on the main thread.
- Must handle bursts of inserts concurrently.

#### Scenario: Background store
- Given Flutter is killed
- Then Kotlin stores to DB successfully
