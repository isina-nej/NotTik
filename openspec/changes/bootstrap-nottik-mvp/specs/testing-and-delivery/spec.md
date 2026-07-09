# Testing and Delivery Specification

## Purpose
Ensure the MVP is stable and runnable.

## Explicit Requirements
- Must pass `flutter analyze` and `flutter test`.
- Must pass `./gradlew lint` and `./gradlew test`.
- Must generate a runnable Debug APK.
- Must be manually tested against simulated notification payloads.

## Out-of-scope
- Comprehensive E2E UI testing (Flutter integration tests are nice to have, but manual coverage is acceptable for MVP delivery if documented).
