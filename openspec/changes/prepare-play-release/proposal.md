# Prepare Play Release

## Why
NotTik needs a clean repository, production-safe release signing, a complete README, and an in-app About page before publication. The current Android release build is signed with the debug key, project documentation is minimal, and there is no visible app page for official links.

## What Changes
- Add production release signing that reads a local `key.properties` file and never falls back to debug signing for release builds.
- Add release documentation and a complete README for users and contributors.
- Add an in-app About page with privacy summary, website link, and GitHub link.
- Clean generated build/cache artifacts without deleting required Gradle wrapper files.
- Verify formatting, analysis, tests, Android build, no `INTERNET` permission, and emulator launch.

## Impact
- Release builds require a local upload keystore.
- Keystore files and `key.properties` remain untracked.
- The app gains one new localized route under Settings.
