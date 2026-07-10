# UI Redesign Specs

## ADDED Requirements

### Requirement: iOS-Style Glassmorphism
The UI SHALL use a heavy blur backdrop and semi-transparent overlay to mimic iOS frosted glass.
   
#### Scenario: Viewing a card in Dark Mode
Given the app is in Dark Mode
When a GlassmorphismCard is rendered
Then it applies a sigmaX/sigmaY blur of 15+
And the background is black with 20% opacity.

### Requirement: Formatted Time Display
The notification items SHALL display a formatted, human-readable time.
   
#### Scenario: Viewing notification time
Given a notification was received at timestamp 1690000000000
When it is rendered in the History list
Then it displays "Time: 14:30" (or similar formatted string) instead of the raw DateTime object string.