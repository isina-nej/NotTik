# Proposal: Polish and Bugfixes

## Motivation
The NotTik MVP is functionally sound (Notification capture, Room DB, Pigeon bridge, basic UI), but contains critical bugs, UI inconsistencies, and missing features that block production release. These issues must be addressed systematically before the next major feature phase.

## Identified Issues
1. **Pigeon Duplicate Files:** Dead/legacy Pigeon files exist in both Kotlin and Flutter sides.
2. **Missing Persian Font:** The `Vazirmatn` font is declared in the theme but missing from `pubspec.yaml` and assets, breaking the RTL UI.
3. **AppMetadataDao Threading:** Dao methods are synchronous, causing potential ANRs or Room strict-mode warnings.
4. **Incomplete JSON Export:** The `ExportUtils` only exports 3 fields, ignoring the actual notification content.
5. **UI & UX Flaws:**
   - `GlassmorphismCard` lacks the actual `BackdropFilter` for the blur effect.
   - History screen pagination `loadMore` causes a full UI rebuild/flash instead of appending.
   - `hasMore` logic in pagination is off-by-one.
   - Hardcoded strings exist across multiple screens instead of using `gen_l10n`.
   - Settings dialogues (Theme, Language, Retention) are empty `TODO` stubs.
6. **Room Database Risk:** `fallbackToDestructiveMigration` causes data loss on schema changes.

## Proposed Solution
Execute a dedicated polish and bugfix sprint to resolve the identified issues, ensuring the app is stable, fully localized, and visually correct.

## Success Criteria
- [ ] No duplicate/dead Pigeon generated code remains.
- [ ] Vazirmatn font is correctly bundled and renders in the app.
- [ ] `AppMetadataDao` uses Kotlin Coroutines (`suspend`) for all operations.
- [ ] JSON export includes full notification content and revisions.
- [ ] `GlassmorphismCard` renders a true blur effect.
- [ ] Pagination loads seamlessly without UI flashing.
- [ ] All hardcoded Persian strings are moved to `.arb` files.
- [ ] Settings dialogs are fully implemented and functional.
- [ ] `fallbackToDestructiveMigration` is removed and an explicit migration path is documented if needed.