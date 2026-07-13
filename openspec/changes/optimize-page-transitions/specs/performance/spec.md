# Performance Spec Delta

## ADDED Requirements

### Requirement: Smooth page transition hot paths
NotTik MUST avoid avoidable expensive work during common page transitions, including History, Apps, Settings, and Detail navigation.

#### Scenario: History page opens with bounded native work
- **GIVEN** the notification listener has captured at least one page of records
- **WHEN** the History page requests its initial page
- **THEN** the native bridge MUST fetch preview data using bounded query work rather than one latest-revision query per visible row.

#### Scenario: Dense list rows avoid per-row own-layer glass
- **GIVEN** a dense scrolling list such as History or Apps
- **WHEN** rows are built for scrolling
- **THEN** each row MUST avoid full own-layer Liquid Glass unless the row is sparse or explicitly marked as a premium hero surface.

### Requirement: Hot Flutter build paths avoid synchronous filesystem checks
Flutter widgets in dense list build paths MUST NOT synchronously check local file existence during `build()`.

#### Scenario: App icon path is invalid
- **GIVEN** a notification row has a stale or invalid local icon path
- **WHEN** Flutter builds the row
- **THEN** the row MUST render without blocking on `File.existsSync()` and MUST fall back through image error handling or a letter/avatar fallback.

#### Scenario: Media path is invalid
- **GIVEN** a notification revision has a stale or invalid local media path
- **WHEN** Flutter builds the revision card
- **THEN** the card MUST render without synchronous file existence checks and MUST show a broken-image fallback if image loading fails.

### Requirement: Performance verification remains local-only
NotTik MUST verify performance without adding network services, telemetry, analytics, or `INTERNET` permission.

#### Scenario: Profile-mode verification
- **GIVEN** a physical Android API 26+ device is available
- **WHEN** the app is run in profile mode
- **THEN** History navigation, Apps navigation, Detail navigation, and list scrolling SHOULD be manually inspected with Flutter performance tooling.

#### Scenario: Privacy constraint preserved
- **GIVEN** performance changes are complete
- **WHEN** the final Android manifest is checked
- **THEN** it MUST NOT include `android.permission.INTERNET`.
