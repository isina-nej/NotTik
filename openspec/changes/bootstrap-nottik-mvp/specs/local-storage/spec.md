# Local Storage Specification

## Purpose
Persist data robustly using native Android tools.

## Explicit Requirements
- Must use Room Database.
- Must implement explicit schema migrations.
- Must not perform DB I/O on the main thread.
- Must handle bursts of inserts concurrently.

## Out-of-scope
- Shared SQLite between Dart and Kotlin directly (Pigeon will act as the bridge).
