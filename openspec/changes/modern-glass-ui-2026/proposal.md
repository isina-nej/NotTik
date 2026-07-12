# Modern Glass UI 2026

## Why
NotTik currently feels MVP-level in key user-facing surfaces. The app has a weak glass effect, flat backgrounds, raw list layouts, incomplete RTL polish, plain dialogs, weak permission onboarding, and inconsistent localized strings. For a notification privacy app, the interface must feel trustworthy, premium, fast, and modern while preserving offline-only behavior.

## What Changes
- Add a modern 2026 iOS-style glass visual system using the existing Flutter stack.
- Upgrade major screens with theme-aware glass backgrounds, cards, dialogs, and modern visual hierarchy.
- Improve History, Detail, Onboarding, Settings, and Apps screens with small scoped changes.
- Fix RTL polish, hardcoded user-facing strings, and obvious crash risks.
- Avoid new dependencies and preserve NotTik privacy constraints.

## Non-Goals
- No internet permission or online services.
- No new design package dependency.
- No native Pigeon contract expansion unless a later task explicitly approves it.
- No broad architecture rewrite.

## Success Criteria
- The visual system reads as real glass on light and dark themes.
- Major screens use modern monitor, inspect, configure, and operate surface patterns.
- Persian RTL layout is visually correct.
- `flutter analyze` and `flutter test` pass or any remaining blocker is documented with evidence.
