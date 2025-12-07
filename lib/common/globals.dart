import 'dart:io';

final kTestMode = Platform.environment.containsKey('FLUTTER_TEST');
const String APP_THEME_STORAGE_KEY = "app_theme";
const String APP_LANGUAGE_STORAGE_KEY = "app_language";
const String CACHE_STORAGE_KEY = "cache";
