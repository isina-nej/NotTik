# NotTik - Autonomous Agent Guidelines

**Project Identity:** NotTik (com.nottik.app)
**Platform:** Android Only (minSdk 26)
**Type:** Flutter UI with Kotlin Native Backend

## Core Rules

1.  **Fully Local:** NO `INTERNET` permission in the final manifest. No backend, no telemetry, no analytics.
2.  **Architecture:**
    *   **Capture:** Native Kotlin `NotificationListenerService`.
    *   **Source of Truth:** Native Room Database (SQLite).
    *   **Bridge:** `pigeon` for typed communication between Flutter and Kotlin.
    *   **UI:** Flutter (Riverpod, go_router, gen_l10n). Feature-first architecture.
3.  **Process:** OpenSpec MUST be used for all feature planning before writing production code.
4.  **Testing Requirements:**
    *   `dart format --set-exit-if-changed .`
    *   `flutter analyze`
    *   `flutter test`
    *   `./gradlew lint`
    *   `./gradlew test`
    *   Manual verification of notification ingestion on API 26+.
5.  **Language:** Persian (Farsi) is the default UI language (RTL). English is supported (LTR).
6.  **Integrity:** No fake implementations. No unsupported privacy claims (e.g., claiming to recover deleted messages not caught by the listener). Do not bypass Android OTP redaction.

*Never use Root or AccessibilityService. Do not overwrite user files destructively.*
