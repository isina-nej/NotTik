# 5. Package Visibility Policy

Date: 2026-07-09

## Status
Accepted

## Context
Android 11+ restricts visibility into installed packages. Requesting `QUERY_ALL_PACKAGES` is likely to get the app rejected from Google Play and looks suspicious.

## Decision
We will not use `QUERY_ALL_PACKAGES`.
We will discover apps in two ways:
1. Querying for apps that respond to `CATEGORY_LAUNCHER` (standard apps).
2. Passively recording the `packageName` of any app that posts a notification to our listener.

## Consequences
- **Positive:** Compliant with Google Play policies. Better privacy.
- **Negative:** A user cannot proactively block a system/hidden app *until* it posts its first notification, because they won't see it in the initial app list.
