# Application Filtering Specification

## Purpose
Allow users to control which applications have their notifications stored.

## Explicit Requirements
- Must support "Mode A: Selected Applications Only" (Opt-in).
- Must support "Mode B: All Applications Except Blocked" (Opt-out).
- Mode changes must take effect immediately.
- Must discover installed applications via Launcher intents.
- Must passively discover hidden applications when they post a notification.

## Out-of-scope
- Using `QUERY_ALL_PACKAGES` to bypass Android 11 visibility rules.
