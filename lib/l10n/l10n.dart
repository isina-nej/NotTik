import 'package:flutter/widgets.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';

// Global l10n instance
late AppLocalizations l10n;

void initL10n(BuildContext context) {
  l10n = AppLocalizations.of(context)!;
}
