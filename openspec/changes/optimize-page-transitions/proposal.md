# Optimize Page Transitions

## Why
NotTik currently shows jank during page transitions and list-heavy screens because history loading and dense list rendering perform expensive work on navigation and rebuild.

The current hot paths include N+1 native history preview queries, missing Room indexes for common history sorting/filtering, synchronous filesystem checks inside Flutter build methods, and full Liquid Glass own-layer cards in dense scrolling lists.

## What Changes
- Optimize native history preview loading to avoid per-row latest-revision queries.
- Add Room indexes for common history sort/filter paths.
- Remove synchronous file existence checks from hot Flutter build paths.
- Keep Liquid Glass aesthetics while using lighter surfaces for dense scrolling rows.
- Add explicit performance verification tasks for profile-mode testing.

## Non-Goals
- No internet permission.
- No backend, telemetry, or analytics.
- No broad UI redesign.
- No removal of Liquid Glass from premium shell, navigation, hero, and settings surfaces.
- No unsupported privacy claims.

## Success Criteria
- Opening the History tab does not perform per-row latest-revision queries.
- Dense scrolling rows avoid per-item own-layer glass where not visually necessary.
- List item build paths do not synchronously check filesystem existence.
- Targeted Dart analysis passes after Flutter UI changes.
- Android lint/test commands are run or blockers are documented with evidence.
- Manual profile-mode verification plan is documented for a physical API 26+ Android device.
