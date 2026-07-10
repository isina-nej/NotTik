# Proposal: UI Original App Icons

## Why
The UI currently displays text initials (like "W") in the Avatar area. To make the app a true premium tier Notification Manager (matching competitors like BuzzKill and Power Shade), we need to display the actual installed Application Icon. The user requested this directly: "برای نوتیف‌ها آیکن خود برنامه و اسم واقی برنامه ست کن".

## What Changes
1. **Add `device_apps`**: We added the `device_apps` package (it operates fully offline) to resolve icons using Android's native `PackageManager`.
2. **Flutter UI Adjustment**: `history_screen.dart` will fetch and display the raw Application icon using `ApplicationWithIcon.icon` inside an `Image.memory`. If not available, it elegantly falls back to the existing initials method.
3. **Detail Screen**: Update `detail_screen.dart` to also show the app icon next to the title.