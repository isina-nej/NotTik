# Proposal: UI Redesign (iOS Glassmorphism & Enhanced Items)

## Why
The current UI looks basic and relies on default Material Design borders. The user explicitly requested an iOS-style glassmorphism aesthetic with a blurred, semi-transparent design. Furthermore, the notification list items currently display the raw `DateTime` string with interpolation bugs (`Time: \${DateTime...}`) and lack the actual app icon instead of a generic bell.

## What Changes
1. **Glassmorphism Base (`app_theme.dart`)**:
   - Redesign `GlassmorphismCard` to strongly mimic iOS frosted glass (more blur, white/black overlays based on dark mode, gradient borders).
2. **History Screen Items (`history_screen.dart`)**:
   - Replace the raw DateTime string with formatted human-readable time (e.g., "14:30").
   - Display the actual App Name clearly and use a distinct layout.
3. **Settings Screen**:
   - Redesign the Settings UI to use inset grouped lists (like iOS Settings) instead of flat ListTiles.