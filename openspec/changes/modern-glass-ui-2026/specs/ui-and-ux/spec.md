# UI and UX Specification Delta

## ADDED Requirements

### Requirement: Modern Glass Visual System
The app MUST use a theme-aware glass visual system for primary surfaces without adding a new package dependency.

#### Scenario: Glass card renders on light and dark themes
- WHEN a primary card is shown on a major screen
- THEN the card SHALL use blur, theme-aware tint, highlight border, and soft depth while preserving readable text contrast.

#### Scenario: Glass appears inside a scrolling list
- WHEN repeated cards are rendered in a scrollable list
- THEN the UI SHALL use a lower-cost glass treatment suitable for smooth scrolling.

### Requirement: Layered Screen Backgrounds
Major user-facing screens MUST provide a layered visual background so glass blur has visible depth behind it.

#### Scenario: User opens a major screen
- WHEN History, Detail, Onboarding, Settings, or Apps is shown
- THEN the screen SHALL render a subtle theme-aware background layer behind primary content.

### Requirement: RTL-Safe Layout
The app MUST avoid hardcoded left/right layout for user-facing UI surfaces.

#### Scenario: Persian UI is rendered
- WHEN the active locale is Persian
- THEN paddings, chevrons, timestamps, and dividers SHALL align correctly for RTL reading direction.

### Requirement: Modern History Composition
The History screen MUST behave as a Monitor/Operate surface optimized for fast scanning and action.

#### Scenario: User views notification history
- WHEN notifications are listed
- THEN the UI SHALL present scannable glass cards with clear app identity, title, time, and state.

#### Scenario: History is empty or fails to load
- WHEN history has no items or an error occurs
- THEN the UI SHALL show a localized glass empty or error state with a clear next action.

### Requirement: Modern Detail Timeline
The Detail screen MUST behave as an Inspect surface with a clear visual timeline.

#### Scenario: User opens notification detail
- WHEN revisions are available
- THEN the UI SHALL show revisions as timeline entries with a visible rail or dot structure.

#### Scenario: Progress data is invalid
- WHEN progress values exceed their expected range
- THEN the UI SHALL clamp progress before rendering.

### Requirement: Premium Permission Onboarding
The Onboarding screen MUST explain notification access with a premium, trust-building glass layout.

#### Scenario: User has not granted notification access
- WHEN onboarding is shown
- THEN the UI SHALL present a focused permission card with privacy, offline, and local-storage benefits.

### Requirement: iOS-Style Settings
The Settings screen MUST use a modern grouped configuration style with glass dialogs.

#### Scenario: User opens a settings dialog
- WHEN language, theme, or retention settings are opened
- THEN the dialog SHALL use the app glass visual language and localized labels.

### Requirement: Modern App Management
The Apps screen MUST behave as an Operate surface for managing per-app logging.

#### Scenario: User views app logging controls
- WHEN apps are listed
- THEN each app SHALL appear as a management card with app identity, package text, status badge, and safe toggle behavior.

#### Scenario: App package name is missing
- WHEN an app item has no package name
- THEN the toggle SHALL be disabled or skipped without throwing an exception.
