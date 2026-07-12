import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RetentionPeriod { days7, days30, days90, forever }

class RetentionSettingsNotifier extends Notifier<RetentionPeriod> {
  static const _key = 'retention_period';

  @override
  RetentionPeriod build() {
    _load();
    return RetentionPeriod.days30; // Default value until loaded
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = RetentionPeriod.values.firstWhere(
        (e) => e.toString() == value, 
        orElse: () => RetentionPeriod.days30
      );
    }
  }

  Future<void> set(RetentionPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, period.toString());
    state = period;
  }
}

final retentionSettingsProvider = NotifierProvider<RetentionSettingsNotifier, RetentionPeriod>(() {
  return RetentionSettingsNotifier();
});
