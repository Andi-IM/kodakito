import 'package:flutter/foundation.dart' show kIsWeb;

// Platform.environment is not available on web, so we default to false
final bool kTestMode = _getTestMode();

bool _getTestMode() {
  // coverage:ignore-start
  if (kIsWeb) return false;
  // coverage:ignore-end
  
  // Dynamically import dart:io only for non-web platforms
  return const bool.fromEnvironment('dart.vm.product') == false &&
      const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
}

const String APP_THEME_STORAGE_KEY = "app_theme";
const String APP_LANGUAGE_STORAGE_KEY = "app_language";
const String CACHE_STORAGE_KEY = "cache";
