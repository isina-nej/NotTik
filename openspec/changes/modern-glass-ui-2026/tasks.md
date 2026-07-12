# Modern Glass UI 2026 - Task List

## 1. Foundation
- [ ] Upgrade `GlassmorphismCard` with theme-aware tint, reusable radius, highlight border, and soft shadow.
- [ ] Add a reusable glass screen background helper for major screens.
- [ ] Reduce blur on list cards to protect scroll performance.
- [ ] Replace deprecated color opacity calls in the theme layer.

## 2. History Screen
- [ ] Replace the plain app bar/search area with a modern glass header composition.
- [ ] Improve notification rows into scannable glass cards.
- [ ] Add localized empty and error states.
- [ ] Reduce repeated app-icon platform work where possible without changing native contracts.

## 3. Detail Screen
- [ ] Replace the header with a glass app identity card.
- [ ] Convert revision cards into a visual timeline with rail and dots.
- [ ] Clamp progress values before rendering.
- [ ] Localize hardcoded detail labels.

## 4. Onboarding Screen
- [ ] Replace the static centered layout with a premium glass permission card.
- [ ] Add privacy, offline, and local-storage benefit chips.
- [ ] Use theme colors instead of hardcoded purple.

## 5. Settings Screen
- [ ] Replace directional-unsafe padding with directional padding.
- [ ] Fix divider indentation and chevrons for RTL.
- [ ] Convert settings dialogs to glass-style dialogs.
- [ ] Localize remaining hardcoded strings.

## 6. Apps Screen
- [ ] Replace the raw switch list with custom management cards.
- [ ] Add fallback letter avatars.
- [ ] Add active/inactive status badges.
- [ ] Guard nullable package names before toggling.
- [ ] Add glass empty and error states.

## 7. Verification
- [ ] Run `flutter gen-l10n`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Review final diff before completion.
