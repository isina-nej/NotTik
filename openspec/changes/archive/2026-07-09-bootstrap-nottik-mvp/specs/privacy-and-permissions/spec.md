## ADDED Requirements

### Requirement: No Exfiltration
- The final AndroidManifest must explicitly NOT declare `android.permission.INTERNET`.

### Requirement: Transparency
- The onboarding flow must clearly state the limitations and data locality.

### Requirement: No Telemetry
- No analytics SDKs, crash reporters, or ad SDKs can be included.

#### Scenario: No internet
- Given the user installs NotTik
- Then OS confirms no network permissions requested
