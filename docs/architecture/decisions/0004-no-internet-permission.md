# 4. No Internet Permission

Date: 2026-07-09

## Status
Accepted

## Context
Users are highly sensitive to privacy when an app requests access to all their notifications. The absolute strongest guarantee we can provide that data is not being exfiltrated is to completely omit the `INTERNET` permission from the app.

## Decision
The final AndroidManifest will not contain `<uses-permission android:name="android.permission.INTERNET" />`. Any feature requiring the internet (like crash reporting or cloud sync) is strictly out of scope.

## Consequences
- **Positive:** Massive trust signal to the user.
- **Negative:** We cannot use standard telemetry, crashlytics, or auto-updating components.
