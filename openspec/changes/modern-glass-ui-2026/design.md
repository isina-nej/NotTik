# Modern Glass UI 2026 Design

## Architecture
Use the existing Flutter UI stack: Material 3, Riverpod, `AppTheme`, generated localization, and current screen files. The work is intentionally scoped to UI composition, theme primitives, RTL correctness, and safe rendering behavior. No new package dependency is introduced.

## Visual System
- `GlassmorphismCard` becomes the single source for glass surfaces.
- Glass uses theme-aware tint, blur, highlight border, and soft shadow.
- Scroll-heavy cards use lower blur to protect performance.
- Major screens get a layered background so blur has visible content behind it.
- Deprecated color opacity calls are removed from the theme layer.

## Screen Strategy
- History is a Monitor/Operate surface: fast scanning, search, tabs, app identity, timestamps, clear empty/error states.
- Detail is an Inspect surface: one notification source, identity header, timeline rhythm, progress safety.
- Onboarding is a Configure/Permission Education surface: focused trust card, offline/privacy/local benefit chips, primary action.
- Settings is a Configure surface: iOS-style grouped lists, RTL-safe affordances, glass dialogs.
- Apps is an Operate surface: management cards, status badges, safe toggles, clear app identity.

## Constraints
- Preserve local-only privacy behavior.
- Avoid broad state-management changes.
- Avoid new dependencies.
- Keep code changes small enough for per-task review.
- Prefer existing localization over hardcoded strings.

## Verification
- Validate OpenSpec change.
- Run localization generation after ARB edits.
- Run Flutter analyzer.
- Run Flutter tests.
- Review final diff before marking tasks complete.
