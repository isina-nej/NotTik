# Privacy and Permissions Specification

## Purpose
Guarantee the user that their captured notifications remain strictly local.

## Explicit Requirements
- The final AndroidManifest must explicitly NOT declare `android.permission.INTERNET`.
- The onboarding flow must clearly state the limitations and data locality.
- No analytics SDKs, crash reporters, or ad SDKs can be included.

## Out-of-scope
- App-level biometric lock (PIN/Fingerprint) for the MVP (delegated to OS level for now).
