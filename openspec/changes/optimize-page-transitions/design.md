# Optimize Page Transitions Design

## Overview
This change reduces navigation and list jank by removing unnecessary native work before Flutter receives data, then reducing expensive per-row rendering work in Flutter. The visual identity remains Liquid Glass, but dense scrolling rows use a lighter surface than hero/navigation/settings chrome.

## Root Causes Found

1. **Native history loading uses N+1 queries**
   - `MainActivity.getLatestHistory()` fetches a page of records, then calls `getLatestRevision(record.id)` for each row.
   - A 20-row page therefore performs at least 21 Room queries.

2. **Room entities lack indexes for common history paths**
   - `notification_records` is filtered by `is_group_summary`, optionally `custom_category`, and sorted by `last_update_time`.
   - `notification_records.package_name` is also used by app filtering and cleanup flows.

3. **Flutter list rows do synchronous filesystem checks during build**
   - `DepthAppBadge` checks `File(path).existsSync()`.
   - History and detail media badges also check `File(mediaPath).existsSync()` in build paths.

4. **Dense rows use full Liquid Glass own layers**
   - `GlassmorphismCard` uses `GlassCard(useOwnLayer: true)`.
   - History and Apps rows wrap every list item in that card.

5. **Multiple history tabs are built from the same data on initial page entry**
   - `TabBarView` constructs three filtered list views, increasing work during page entry and provider updates.

## Proposed Approach

### Native data layer
- Add a dedicated Room projection for history preview rows.
- Query records and latest revisions in one bounded query instead of per-row lookup.
- Add conservative indexes for sort/filter fields.
- Keep Pigeon DTO shape unchanged unless unavoidable.

### Flutter UI layer
- Keep `GlassmorphismCard` for large, sparse, premium surfaces.
- Add a lightweight list card for dense History and Apps rows.
- Remove synchronous `existsSync()` checks from hot build paths; trust paths and use `Image.file` `errorBuilder` for fallback.
- Add `cacheWidth`/`cacheHeight` for small icon decode where practical.
- Add `RepaintBoundary` around static ambient background or other expensive static layers.

### Verification
- Run targeted Dart analysis after each Flutter step.
- Run full Flutter and Android quality gates before completion.
- Use profile mode on a physical Android device to manually verify navigation and scrolling.

## Constraints
- Final manifest must not add `INTERNET`.
- Native database remains the source of truth.
- Flutter/Kotlin communication remains Pigeon-based.
- Persian RTL remains default.
- Existing uncommitted user changes must not be overwritten destructively.
