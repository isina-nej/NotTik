You are the lead autonomous software architect, Android engineer, Flutter engineer, UX engineer, QA engineer, and technical researcher responsible for building a complete, runnable Android MVP named **NotTik**.

Your responsibility is not merely to generate sample code. You must research, plan, specify, implement, test, debug, document, and deliver a working Android application.

Communicate progress reports and final explanations in Persian. Keep source code, identifiers, filenames, comments, commit messages, technical documents, and OpenSpec artifacts in professional English unless Persian is explicitly required for localized UI content.

# 1. Core operating rules

You must follow these rules throughout the entire task:

1. Do not start implementation immediately.
2. Research current official documentation before making architectural or dependency decisions.
3. Use OpenSpec before writing production code.
4. Create a concrete implementation plan before modifying the project.
5. Treat OpenSpec specifications as the source of truth.
6. Never invent APIs, Android behavior, package versions, Flutter APIs, Gradle settings, or plugin capabilities.
7. Prefer current official primary sources:

   * developer.android.com
   * docs.flutter.dev
   * dart.dev
   * kotlinlang.org
   * pub.dev packages from verified publishers
   * official GitHub repositories
   * official OpenSpec documentation
8. Record research findings, dates, sources, decisions, rejected alternatives, and compatibility notes.
9. Use Hermes tools proactively:

   * terminal and process tools
   * file search and editing
   * web search and browser tools
   * todo/task tracking
   * delegate_task for parallel research
   * memory for durable project facts
   * skills for reusable procedures
10. Do not ask the user questions unless execution is genuinely blocked by missing credentials, missing hardware, destructive system changes, or an unresolvable product contradiction.
11. Make reasonable engineering decisions independently and document them as ADRs.
12. Never use root access, AccessibilityService, screen scraping, private APIs, exploit techniques, or permission bypasses.
13. Do not claim that NotTik can recover deleted messages. It only stores notification content that Android previously exposed to the app.
14. Never attempt to bypass Android redaction, OTP protection, app privacy controls, or operating-system restrictions.
15. Do not delete existing user files or overwrite unrelated work.
16. Before destructive commands, inspect the target and create a backup or Git checkpoint.
17. Use Git for incremental checkpoints, but do not push to a remote repository unless explicitly instructed.
18. Continue until a runnable MVP is produced or an external environment limitation makes execution impossible.
19. When an external limitation occurs, still complete all code and provide the exact remaining command or manual step.
20. Do not leave placeholder implementations, TODO-only methods, fake repositories, mock production services, or unimplemented buttons in the final MVP.

# 2. Project identity

Application name:

NotTik

Android application ID and namespace:

com.nottik.app

Target platform:

Android only

Minimum supported Android version:

Android 8.0, API level 26

Application type:

Flutter application with native Android functionality written in Kotlin.

Initial semantic version:

0.1.0+1

The application must be fully local:

* No backend
* No login or account
* No cloud database
* No Firebase
* No analytics SDK
* No advertising SDK
* No telemetry
* No crash-reporting service
* No remote configuration
* No user tracking
* No INTERNET permission in the final Android manifest
* No network calls from the application
* All captured information must remain inside the device unless the user explicitly exports or shares it

# 3. Mandatory research phase

Before planning or coding, create:

docs/research/research-log.md

The research log must include:

* Research date
* Exact source
* Relevant version
* Finding
* Impact on NotTik
* Chosen approach
* Rejected alternatives
* Remaining risk

Use parallel Hermes subagents where useful to investigate these areas independently:

## Research lane A: Android notification access

Research current official Android behavior for:

* NotificationListenerService
* onNotificationPosted
* onNotificationRemoved
* removal reasons on API 26+
* onListenerConnected
* requestRebind
* notification access settings intent
* notification listener manifest declaration
* Android notification extras
* MessagingStyle notifications
* grouped notifications
* notification channels
* media notifications
* ongoing notifications
* progress notifications
* custom RemoteViews limitations
* large icons and big pictures
* Android 13 notification permission relevance
* Android 14, Android 15, and later notification restrictions
* sensitive notification and OTP redaction
* OEM restrictions and battery behavior
* notification listener access after reboot or process death

## Research lane B: Flutter architecture

Research current stable and compatible choices for:

* Latest stable Flutter and Dart
* Kotlin and Android Gradle Plugin compatibility
* Riverpod
* go_router
* Flutter localization using gen_l10n
* RTL and Persian support
* Pigeon for typed Kotlin–Flutter communication
* Material 3
* adaptive light and dark themes
* performance implications of blur and glassmorphism

## Research lane C: native persistence

Evaluate and document:

* Native Room database as the source of truth
* Drift database controlled by Flutter
* Shared SQLite database accessed by both Kotlin and Dart
* JSON/file-based storage
* Native Room plus Pigeon bridge

The architecture must remain reliable when:

* Flutter is not running
* MainActivity has been destroyed
* The user swipes the app away
* A notification arrives while the UI is closed
* Multiple notification updates arrive quickly
* Flutter reads while Kotlin writes

The preferred architecture is:

* Kotlin NotificationListenerService captures notifications.
* Kotlin processes and persists them.
* Native Room owns the database.
* Flutter accesses the native data layer through generated Pigeon APIs.
* Flutter does not need to be alive for capture to work.

Use this architecture unless official research reveals a material incompatibility. Any change must be justified in an ADR.

## Research lane D: Android package visibility

Research:

* Android 11+ package visibility restrictions
* Listing launchable applications
* Packages discovered from observed notifications
* `<queries>` manifest declarations
* Google Play restrictions around `QUERY_ALL_PACKAGES`

Do not add `QUERY_ALL_PACKAGES` automatically.

Prefer a policy-compatible design:

* Show launchable visible apps.
* Add packages as they are observed by the notification listener.
* Support capture-all-except-blocked without requiring a complete installed-app list.
* Document any visibility limitation clearly.

## Research lane E: storage and background cleanup

Research:

* Room migrations
* Room WAL and concurrency
* Room FTS support
* Android WorkManager
* periodic work limitations
* unique periodic work
* cleanup scheduling
* Storage Access Framework
* local ZIP backup and restore
* internal app-private image storage

# 4. OpenSpec is mandatory

Before implementation, verify the environment:

```bash
node --version
npm --version
flutter --version
dart --version
java -version
adb version
git --version
```

OpenSpec requires Node.js 20.19.0 or newer. Verify the currently installed requirement from official OpenSpec documentation before proceeding.

Install or update OpenSpec:

```bash
npm install -g @fission-ai/openspec@latest
openspec --version
```

Initialize it in the NotTik project.

Because Hermes may not have an official OpenSpec adapter, use:

```bash
openspec init --tools none
```

Then inspect:

```bash
openspec --help
openspec config --help
openspec list
openspec view --help
```

Enable the most complete appropriate workflow available in the installed OpenSpec version, including at least:

* explore
* propose
* apply
* update
* verify
* sync
* archive

If OpenSpec command names or configuration syntax have changed, use the current official documentation and installed CLI help instead of blindly following old commands.

Create the OpenSpec change:

```text
bootstrap-nottik-mvp
```

Before any production implementation, create and validate these artifacts:

```text
openspec/
  changes/
    bootstrap-nottik-mvp/
      proposal.md
      design.md
      tasks.md
      specs/
        notification-capture/
          spec.md
        application-filtering/
          spec.md
        notification-history/
          spec.md
        categories-and-search/
          spec.md
        local-storage/
          spec.md
        media-storage/
          spec.md
        retention-and-cleanup/
          spec.md
        export-backup-restore/
          spec.md
        localization-and-theme/
          spec.md
        privacy-and-permissions/
          spec.md
        testing-and-delivery/
          spec.md
```

Each specification must contain:

* Purpose
* Scope
* Explicit requirements
* User scenarios
* Acceptance criteria
* Edge cases
* Failure states
* Out-of-scope behavior
* Testable examples

The design document must contain:

* System context
* Container/component architecture
* Native lifecycle
* Flutter lifecycle
* Kotlin–Flutter communication
* Threading model
* persistence model
* database schema
* image-storage strategy
* notification revision strategy
* package-visibility strategy
* cleanup strategy
* backup/restore strategy
* localization strategy
* theme/design system
* error handling
* observability without telemetry
* performance considerations
* privacy and threat model
* testing strategy
* known Android limitations

Create ADR files under:

```text
docs/architecture/decisions/
```

At minimum:

```text
0001-native-room-source-of-truth.md
0002-pigeon-native-bridge.md
0003-notification-revision-model.md
0004-no-internet-permission.md
0005-package-visibility-policy.md
0006-local-media-storage.md
0007-workmanager-retention-cleanup.md
```

Do not begin production code until:

* Research is complete.
* OpenSpec artifacts exist.
* Requirements are internally consistent.
* Tasks are broken into small verifiable units.
* Architecture decisions have been documented.
* The plan has been printed to the user in Persian.

The user has already approved the product requirements in this prompt. Do not pause for approval after planning unless a blocking contradiction is discovered.

# 5. Hermes-specific workflow

Create a concise root-level:

```text
AGENTS.md
```

It must permanently state:

* Project identity
* Android-only scope
* minSdk 26
* package ID
* local-only policy
* no INTERNET permission
* Kotlin native notification capture
* Room source of truth
* Pigeon bridge
* Feature-first Flutter architecture
* OpenSpec-before-code requirement
* current testing commands
* formatting and lint requirements
* localization requirements
* no fake implementations
* no unsupported privacy claims

Keep AGENTS.md concise enough not to waste the context window.

Use Hermes memory for durable facts such as:

* Project location
* Package ID
* Flutter version
* selected architecture
* build commands
* device/emulator configuration
* major resolved compatibility issues

Use Hermes skills for repeatable procedures.

After the first successful OpenSpec implementation cycle, create or improve a reusable Hermes skill named similarly to:

```text
nottik-openspec-workflow
```

The skill should define:

* Research
* OpenSpec proposal
* design
* tasks
* implementation
* testing
* verification
* spec synchronization
* archive
* final reporting

Do not save temporary errors or short-lived package versions as durable memory unless they materially affect future work.

Use `delegate_task` for parallel research or isolated test investigations, but Hermes remains the coordinator and must reconcile every result against the actual repository.

# 6. Product behavior

NotTik archives notification history from applications selected by the user.

It must support two capture modes:

## Mode A: selected applications only

Only store notifications from applications explicitly selected by the user.

## Mode B: all applications except blocked

Store every notification exposed to the listener except notifications from applications explicitly blocked by the user.

The user must be able to switch between these modes.

Mode changes must take effect without reinstalling or resetting the app.

# 7. Notification capture requirements

Implement the notification listener natively in Kotlin.

The service must:

* Receive newly posted notifications.
* Receive notification updates.
* Receive notification removal events.
* Continue functioning while Flutter UI is closed.
* Persist data asynchronously.
* Avoid blocking the Android main thread.
* Handle bursts of notification events safely.
* Survive malformed or incomplete notification data.
* Avoid crashes caused by inaccessible icons, bundles, parcelables, or custom notification layouts.
* Never rely on Flutter being active.
* Record the notification before attempting expensive image extraction.
* Handle duplicate callbacks idempotently.

Capture all notification types Android exposes, including when available:

* Messaging notifications
* Social notifications
* Calls
* Missed calls
* Media playback
* Downloads
* Progress
* Navigation
* Reminders
* Events
* Email
* Promotions
* Alarms
* System status
* VPN status
* Ongoing notifications
* Group summaries
* Custom or unknown categories
* Silent notifications
* Notifications without visible text

Extract as much of the following data as Android legally and technically exposes:

* Android notification key
* package name
* application display name
* notification ID
* tag
* user/profile identifier when available
* post time
* first captured time
* last update time
* removal time
* removal reason
* group key
* sort key
* channel ID
* category
* visibility
* priority or importance where available
* flags
* color
* badge number
* ticker text
* title
* text
* subtext
* big text
* summary text
* info text
* text lines
* conversation title
* sender names
* MessagingStyle messages
* message timestamps
* historic messages if exposed
* people/person metadata when exposed
* progress maximum
* progress value
* indeterminate progress
* ongoing status
* clearable status
* group-summary status
* small icon metadata
* large icon
* big picture
* application icon
* shortcut ID
* conversation ID
* content intent availability
* content fingerprint/hash
* raw non-sensitive diagnostic metadata where safe

Do not serialize arbitrary Android Parcelables blindly.

Create a safe extractor that:

* Uses typed access.
* Catches per-field failures.
* Records extraction warnings locally.
* Does not fail the entire notification because one field is unavailable.
* Limits text and binary sizes.
* Avoids storing executable Intent objects.
* Does not log sensitive notification content in Logcat for release builds.

# 8. Notification revisions

All changed versions of a notification must be preserved.

Define a stable logical identity based on Android notification identity, including:

* notification key when available
* package name
* notification ID
* tag
* user/profile identifier

Use a parent record plus immutable revisions, or another normalized design justified in the architecture document.

Each materially changed notification callback must create a new revision.

A revision should include:

* revision number
* capture timestamp
* content hash
* all extracted text fields
* progress state
* media references
* relevant metadata

Avoid creating a new revision for a byte-for-byte or semantically identical callback unless official Android behavior makes such storage necessary.

Store removal metadata, but do not present notifications in the main user interface with a misleading “deleted message” or “sender deleted this” label.

The UI should simply present notification history.

# 9. OTP and sensitive content

Store sensitive notification content only if Android exposes it normally through NotificationListenerService.

Requirements:

* Do not bypass redaction.
* Do not use accessibility services.
* Do not use OCR or screenshots.
* Do not infer hidden OTP values.
* Do not claim unsupported access.
* Gracefully store a redacted or empty record when Android hides the content.
* Document this limitation in onboarding, README, and privacy documentation.
* Consider a user option for excluding probable OTP/security notifications, but do not enable exclusion unless specified by the product spec or justified as a safe default in OpenSpec.

# 10. Persistence architecture

Preferred native data stack:

* Kotlin
* Room
* Coroutines
* Flow
* WorkManager
* app-private file storage
* Pigeon-generated typed APIs

Room must be the single database owner unless research proves another approach safer.

Requirements:

* No database access on the main thread.
* Explicit migrations.
* Export Room schema files.
* Migration tests.
* WAL or another appropriate concurrency configuration.
* Transactional writes.
* Foreign keys where appropriate.
* Proper indexes.
* Paginated history queries.
* Search optimized for notification text.
* No destructive migration in production.
* No silent database reset after schema changes.
* Repository and DAO interfaces must be testable.

Possible entities include, but are not limited to:

* CapturedApplication
* ApplicationCaptureRule
* NotificationRecord
* NotificationRevision
* NotificationRemovalEvent
* StoredMedia
* UserCategory
* NotificationCategoryCrossReference
* Favorite
* AppRetentionPolicy
* AppMediaPolicy
* UserPreference
* BackupMetadata

Design the final schema from requirements rather than copying this list mechanically.

# 11. Media storage

When available, store:

* app icon
* large notification icon
* big picture
* messaging avatar if exposed

Requirements:

* Store files in application-private storage.
* Do not request gallery/storage permissions merely to retain captured media.
* Use normalized filenames.
* Maintain database references.
* Create thumbnails where useful.
* Compress images using a justified format.
* Set maximum dimensions and maximum file size.
* Deduplicate identical images using content hashes.
* Delete orphaned files.
* Delete media when its notification is permanently removed by the user or retention cleanup.
* Gracefully handle corrupt or unsupported images.
* Never block notification ingestion on image compression.

# 12. Native bridge

Use Pigeon for typed communication between Flutter and Kotlin unless current official guidance identifies a better type-safe option.

Expose typed APIs for:

* notification access status
* opening notification access settings
* requesting listener rebind
* capture mode
* application list
* application capture rules
* history pagination
* history detail
* revision list
* search
* filters
* categories
* favorites
* deleting one item
* bulk deleting
* statistics
* retention settings
* media settings
* cleanup status
* export
* backup
* restore
* database/storage size
* listener diagnostics

Provide a native-to-Flutter change notification mechanism so the open Flutter UI can refresh when new data is captured.

Use a generated callback API or a narrowly scoped event channel if necessary.

Do not continuously transfer the entire database to Flutter.

Use pagination and lightweight DTOs.

# 13. Flutter architecture

Use a feature-first architecture with Data, Domain, and Presentation layers.

Recommended structure:

```text
lib/
  app/
    bootstrap/
    routing/
    localization/
    theme/
    design_system/
  core/
    errors/
    result/
    platform/
    utils/
    widgets/
  features/
    onboarding/
      data/
      domain/
      presentation/
    dashboard/
      data/
      domain/
      presentation/
    history/
      data/
      domain/
      presentation/
    notification_detail/
      data/
      domain/
      presentation/
    applications/
      data/
      domain/
      presentation/
    categories/
      data/
      domain/
      presentation/
    search/
      data/
      domain/
      presentation/
    statistics/
      data/
      domain/
      presentation/
    backup_restore/
      data/
      domain/
      presentation/
    settings/
      data/
      domain/
      presentation/
```

Use the current stable and compatible versions of:

* flutter_riverpod
* riverpod_annotation and code generation when justified
* go_router
* Pigeon
* Flutter gen_l10n
* intl
* immutable/value-equatable patterns appropriate to the selected Dart version

Avoid unnecessary dependencies.

Before adding every package:

* Verify maintenance status.
* Verify latest stable release.
* Verify SDK compatibility.
* Verify Android support.
* Verify license.
* Record the decision in the research log.

# 14. UI and design system

The user interface must support:

* Persian
* English
* Persian as the default language
* Full RTL in Persian
* Full LTR in English
* Light theme
* Dark theme
* System theme
* Runtime language switching
* Runtime theme switching

Visual direction:

* Minimal
* Premium
* iOS-inspired
* Soft glass surfaces
* Rounded cards
* Clear hierarchy
* Spacious layout
* Subtle shadows
* Subtle borders
* Smooth animations
* Modern system-blue-inspired accent palette
* High readability
* Not a direct visual copy of iOS

Use semantic color tokens.

Research current Apple-like light and dark semantic color behavior, then translate the principles into an original Flutter Material 3 design.

Glassmorphism rules:

* Use blur sparingly.
* Do not apply BackdropFilter to every scrolling list item.
* Avoid excessive GPU cost.
* Provide an opaque fallback.
* Maintain sufficient text contrast.
* Respect reduce-motion or accessibility considerations where possible.
* Prefer translucent surfaces and gradients over expensive nested blurs.

Use placeholder logo and splash assets that can easily be replaced later.

# 15. Required screens

Implement at least these complete screens:

## Splash/bootstrap

* Local initialization
* database initialization
* migration handling
* theme and locale loading
* listener status check

## Onboarding

Explain clearly:

* NotTik stores notifications only after permission is granted.
* It cannot recover notifications from before installation or permission.
* It cannot guarantee access to redacted content.
* Data stays on the device.
* The user can choose which apps are monitored.

Include:

* privacy explanation
* notification-access status
* button to open Android notification-access settings
* capture-mode selection
* initial app selection
* completion state

## Dashboard

Show useful local summaries:

* notifications today
* active monitored apps
* total stored history
* storage used
* recent notifications
* top categories
* quick access to search and filters

## History

Provide:

* infinite or paginated scrolling
* grouping by date
* application icon
* app name
* title
* text preview
* timestamp
* category
* favorite state
* empty state
* error state
* loading skeleton
* pull to refresh

## Notification detail

Show:

* complete stored content
* application details
* timestamps
* images
* extracted fields
* revisions
* copy action
* share action
* favorite action
* delete action

Do not display a “deleted by sender” label.

## Revision history

Display all captured versions chronologically.

Make differences understandable, but do not falsely explain why the source application changed them.

## Applications

Provide:

* capture-mode selector
* selected apps
* blocked apps
* observed apps
* visible launchable apps
* search
* per-app enable/disable
* per-app retention override
* per-app image-storage toggle
* app notification count
* last seen time

## Categories

Provide default categories such as:

* All
* Messages
* Social
* Calls
* Email
* Media
* Downloads
* Progress
* Navigation
* Events
* Reminders
* Promotions
* Security
* System
* Ongoing
* Unknown

Also support:

* user-created categories
* manual category assignment
* category rename
* category delete
* custom tags if they fit the approved architecture

## Search and filters

Search across available text fields.

Filters must include:

* application
* date range
* category
* favorite
* media present
* notification type
* ongoing status
* removed status internally if useful
* custom category/tag

Sort options:

* newest first
* oldest first
* application
* category

## Statistics

Provide local statistics such as:

* notifications per day
* notifications per application
* notifications per category
* busiest hour
* storage usage
* text records versus media records
* retained revision count

Use lightweight Flutter charts only if the selected package is actively maintained and justified. Otherwise implement simple native Flutter visualizations without an additional chart dependency.

## Backup and export

Provide:

* JSON export
* CSV export
* local backup archive
* restore from local backup
* Android Storage Access Framework
* progress
* cancellation where possible
* success/failure reports

Backup must include:

* database data
* media files
* user settings
* manifest with schema/app version
* checksums where practical

Restore must:

* validate format
* validate version
* reject corrupt archives safely
* avoid partial restore
* use transactional or staged replacement
* preserve the current installation if restore fails

## Settings

Include:

* language
* theme
* capture mode
* monitored apps
* blocked apps
* automatic cleanup toggle
* default retention period
* per-app retention access
* image capture default
* storage usage
* clear all data
* export
* backup
* restore
* privacy explanation
* limitations
* app version
* listener diagnostics

# 16. Retention and automatic cleanup

Automatic cleanup must be optional.

The user can:

* enable it
* disable it
* select a default retention duration
* choose never delete
* set per-app overrides

Suggested durations:

* 7 days
* 30 days
* 90 days
* custom duration
* never

Use native WorkManager for reliable scheduled cleanup.

Requirements:

* Use unique work.
* Cancel scheduled work when cleanup is disabled.
* Reconfigure work when settings change.
* Run an immediate cleanup when appropriate.
* Do not require exact alarms.
* Remove associated media safely.
* Produce a local cleanup result.
* Avoid blocking notification ingestion.
* Test retention boundaries.
* Never delete favorites if the user enables an optional “keep favorites” rule.

# 17. User actions

Implement all of these:

* search notifications
* filter notifications
* sort notifications
* copy text
* share text using Android share sheet
* favorite/unfavorite
* delete one notification
* select multiple notifications
* bulk delete
* delete by app
* delete by date range
* clear all history with explicit confirmation
* export JSON
* export CSV
* create local backup
* restore local backup
* configure monitored apps
* configure blocked apps
* configure retention
* configure media capture
* switch language
* switch theme

# 18. Privacy and safety

Create:

```text
docs/privacy.md
```

It must accurately state:

* NotTik uses Android notification access.
* It stores exposed notification content locally.
* It has no backend.
* It has no analytics.
* It has no INTERNET permission.
* It does not recover historical messages.
* It does not guarantee access to deleted, hidden, encrypted, or redacted content.
* Exported files are controlled by the user.
* Anyone with physical access to an unlocked device may be able to open NotTik because the MVP has no app lock.
* Database encryption is not enabled in this MVP.

Do not implement:

* authentication
* PIN
* biometric lock
* encryption layer
* cloud sync
* hidden monitoring
* stealth mode
* background microphone/camera access
* contact collection
* location collection
* accessibility service
* root functionality

# 19. Performance requirements

Design for large local histories.

Requirements:

* Pagination
* indexed queries
* no unbounded database fetches
* lazy image loading
* thumbnail use
* background image processing
* cancellation for stale searches
* debounce text search
* efficient Riverpod provider scopes
* stable list keys
* minimal rebuilds
* no blur per list row
* database writes off the main thread
* bounded media size
* bounded DTO payloads across Pigeon
* release-mode logging restrictions

Establish reasonable MVP targets and document them, for example:

* smooth history scrolling with thousands of records
* initial history page below a reasonable latency threshold on a normal device
* no application crash on malformed notifications
* notification persistence independent of Flutter lifecycle

Do not invent benchmark results. Measure when possible and clearly label unmeasured targets.

# 20. Error handling

Create a typed error model across Kotlin and Flutter.

Handle:

* notification access disabled
* listener disconnected
* app package removed
* inaccessible app icon
* inaccessible notification image
* malformed notification bundle
* database migration failure
* database full
* low disk space
* corrupted media file
* failed export
* failed backup
* failed restore
* unsupported backup version
* WorkManager failure
* Pigeon communication failure
* empty or redacted notification content

User-facing errors must be localized.

Technical details should be available in a diagnostics view without exposing private notification content unnecessarily.

# 21. Testing requirements

Implement meaningful tests, not empty test files.

## Kotlin unit tests

Test:

* capture mode rules
* selected-app mode
* all-except-blocked mode
* logical notification identity
* content hashing
* revision creation
* identical-update deduplication
* notification field extraction
* missing extras
* malformed bundles
* category mapping
* media-size limits
* cleanup calculation
* retention overrides
* export serialization

## Room tests

Test:

* DAO inserts
* transactions
* pagination
* search
* filters
* parent/revision relations
* deletion cascades
* media cleanup references
* migrations
* backup staging where possible

## Flutter unit and widget tests

Test:

* Persian default locale
* RTL layout
* English LTR layout
* light theme
* dark theme
* history loading
* empty states
* error states
* search
* filters
* application selection
* retention settings
* settings persistence
* backup/restore UI states

## Integration/manual tests

Create:

```text
docs/testing/manual-test-plan.md
```

Cover at least:

* Android 8/API 26
* Android 10
* Android 12
* Android 13
* Android 14
* Android 15 or current available target
* listener permission grant/revoke
* app process killed
* Flutter UI closed
* device reboot
* notification updated repeatedly
* grouped messages
* media notification
* download progress
* ongoing notification
* redacted notification
* blocked app
* selected-only mode
* cleanup enabled/disabled
* backup/restore
* Persian/English
* light/dark mode

Use emulators and a physical device if available.

Do not claim a physical-device test if none occurred.

# 22. Build and quality gates

Before declaring completion, run the current equivalents of:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
cd android
./gradlew test
./gradlew lint
./gradlew assembleDebug
```

Also run:

* generated-code verification
* Room schema export verification
* migration tests
* OpenSpec verification
* dependency audit
* manifest inspection
* APK permission inspection

Confirm that the final merged manifest does not contain:

```text
android.permission.INTERNET
```

Inspect the built APK using available Android tooling and verify the package ID.

The final APK must be produced when the environment supports Android builds.

Report the exact APK path.

Do not silence warnings merely to pass checks.

Fix the underlying issue when practical.

# 23. Implementation order

Implement in vertical slices:

1. Environment and OpenSpec initialization
2. Research and architecture
3. Flutter project bootstrap
4. Localization and themes
5. Native Room database
6. Pigeon contract
7. NotificationListenerService
8. Notification extraction
9. Capture filtering
10. Revision persistence
11. Onboarding and permission flow
12. History list and details
13. Application management
14. Categories and search
15. Favorites and bulk actions
16. Statistics
17. Retention and WorkManager
18. Export
19. Backup and restore
20. Diagnostics and settings
21. Tests
22. performance review
23. privacy review
24. final OpenSpec verification
25. build and delivery

After every slice:

* run relevant tests
* update OpenSpec tasks.md
* update research/design documentation if reality differs
* make a local Git checkpoint
* report concise progress in Persian

# 24. OpenSpec completion

Before archiving the change:

1. Verify every task is completed.
2. Compare implementation against every requirement.
3. Check completeness.
4. Check correctness.
5. Check architectural coherence.
6. Check test coverage.
7. Check documentation.
8. Check the final manifest.
9. Check privacy claims.
10. Check no placeholder code remains.
11. Run the OpenSpec verification workflow.
12. Resolve every critical issue.
13. Document accepted warnings.
14. Sync specifications.
15. Archive the change only after the MVP passes quality gates.

If Hermes cannot directly invoke `/opsx:*` commands, reproduce the same OpenSpec workflow using:

* OpenSpec CLI
* current OpenSpec artifact templates
* the `openspec/changes/` structure
* explicit verification against specs
* OpenSpec validation/list/view commands available in the installed version

The absence of a Hermes-specific adapter is not permission to skip OpenSpec.

# 25. Required documentation

Deliver:

```text
README.md
AGENTS.md
docs/research/research-log.md
docs/architecture/architecture.md
docs/architecture/decisions/*.md
docs/privacy.md
docs/testing/manual-test-plan.md
docs/testing/test-results.md
docs/limitations.md
docs/backup-format.md
docs/database-schema.md
docs/native-bridge.md
```

README must contain:

* product overview
* honest limitations
* architecture
* prerequisites
* Flutter setup
* Android setup
* code generation
* build commands
* test commands
* notification access instructions
* project structure
* localization
* backup format
* troubleshooting
* release APK location

# 26. Final definition of done

NotTik MVP is complete only when:

* It builds successfully.
* It launches on Android.
* Package ID is `com.nottik.app`.
* minSdk is 26.
* Persian is the default language.
* English is supported.
* RTL and LTR work.
* Light and dark themes work.
* Notification access onboarding works.
* Kotlin listener receives available notifications.
* Notifications are stored while Flutter is closed.
* Both capture modes work.
* Updated notification revisions are stored.
* Images are retained when exposed.
* History is paginated.
* Search and filters work.
* Categories work.
* Favorites work.
* Delete and bulk delete work.
* Copy and share work.
* Statistics work.
* Automatic cleanup can be enabled and disabled.
* Per-app policies work.
* JSON and CSV exports work.
* Local backup and restore work.
* No backend exists.
* No analytics exists.
* No INTERNET permission exists.
* Tests pass.
* OpenSpec verification passes without unresolved critical issues.
* Documentation is complete.
* A debug APK is generated when the environment supports it.

# 27. Final report format

At completion, provide a Persian report containing:

1. Overall status
2. What was implemented
3. Architecture selected
4. Important research findings
5. OpenSpec change status
6. Main project paths
7. Database design summary
8. Native bridge summary
9. Permissions used
10. Test commands and exact results
11. Build command and result
12. APK path
13. Known Android limitations
14. Any untested device scenarios
15. Remaining non-blocking improvements
16. Exact instructions for running the application

Do not state “everything works” without test evidence.

Begin now by inspecting the current working directory and environment. Then perform the mandatory research phase and initialize OpenSpec. Do not write production code before the OpenSpec planning artifacts are ready.
