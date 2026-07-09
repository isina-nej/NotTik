# testing-and-delivery Specification

## Purpose
TBD - created by archiving change bootstrap-nottik-mvp. Update Purpose after archive.
## Requirements
### Requirement: Quality Gates
- Must pass `flutter analyze` and `flutter test`.
- Must pass `./gradlew lint` and `./gradlew test`.

### Requirement: Artifacts
- Must generate a runnable Debug APK.
- Must be manually tested against simulated notification payloads.

#### Scenario: Build APK
- Given the project is clean
- Then the debug APK builds successfully

