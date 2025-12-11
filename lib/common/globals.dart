import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

// Platform.environment is not available on web, so we default to false
final bool kTestMode = _getTestMode();

bool _getTestMode() {
  // coverage:ignore-start
  if (kIsWeb) return false;
  // coverage:ignore-end

  // Check Platform.environment for FLUTTER_TEST (set by flutter test command)
  return Platform.environment.containsKey('FLUTTER_TEST') ||
      const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
}

const String APP_THEME_STORAGE_KEY = "app_theme";
const String APP_LANGUAGE_STORAGE_KEY = "app_language";
const String CACHE_STORAGE_KEY = "cache";
