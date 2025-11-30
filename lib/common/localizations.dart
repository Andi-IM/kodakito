import 'package:dicoding_story/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:dicoding_story/l10n/app_localizations.dart';
export 'package:flutter_localizations/flutter_localizations.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}