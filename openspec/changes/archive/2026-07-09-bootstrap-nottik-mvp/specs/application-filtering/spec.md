## ADDED Requirements

### Requirement: Mode A
- Must support "Mode A: Selected Applications Only" (Opt-in).

### Requirement: Mode B
- Must support "Mode B: All Applications Except Blocked" (Opt-out).

### Requirement: Real-time Changes
- Mode changes must take effect immediately.

### Requirement: App Discovery
- Must discover installed applications via Launcher intents.
- Must passively discover hidden applications when they post a notification.

#### Scenario: Filter modes
- Given the user changes the filter mode
- Then subsequent notifications adhere to the new rule
