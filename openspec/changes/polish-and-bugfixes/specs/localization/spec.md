# Localization Specification

## 1. Hardcoded Strings Removal
**Goal:** All user-facing text must use `gen_l10n`.
**Actions:**
- Identify hardcoded strings in:
  - `history_screen.dart` ("جستجو...", "هیچ نوتیفیکیشنی یافت نشد.", "بارگذاری بیشتر")
  - `apps_screen.dart` ("برنامه‌ها", "هنوز هیچ برنامه‌ای ثبت نشده است.")
  - `settings_screen.dart` ("عمومی", "زبان", "پوسته (تم)", "داده‌ها و حافظه", etc.)
- Add these to `app_fa.arb` and `app_en.arb`.
- Run `flutter gen-l10n`.
- Replace hardcoded text with `l10n` calls.