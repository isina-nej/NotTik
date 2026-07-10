# Design: UI Redesign (iOS Glassmorphism & Enhanced Items)

## High-Level Architecture
1. **Theme Adjustments**: We will modify `AppTheme.dart` to rely less on flat colors and more on `BackdropFilter` with `BoxDecoration` gradients. This will create the "iOS frosted glass" look across both Light and Dark modes.
2. **Formatting**: Dart's `intl` package will be used in `history_screen.dart` to format `record.postTime` into a readable `HH:mm` format.
3. **App Icons**: For the MVP, we will try to parse the first letter of the App Name as an Avatar, or use a customized, elegant icon instead of the generic material bell, since native Android icon extraction requires saving Bitmaps which we already do but might be heavy for a list view.
4. **Layout**: We will use `ListView.separated` or grouped layouts for the Settings to make it look like an iOS Settings page.