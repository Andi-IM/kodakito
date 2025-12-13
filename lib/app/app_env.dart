import 'package:flutter/foundation.dart';

// coverage:ignore-file
enum AppEnvironment { development, production, proDevelopment, pro }

abstract class EnvInfo {
  static AppEnvironment _environment = AppEnvironment.development;

  static AppEnvironment get environment => _environment;

  static void initialize(AppEnvironment environment) {
    EnvInfo._environment = environment;
  }

  static String get appName => _environment._appTitle;

  static String get env => _environment._env;

  static bool get isProduction =>
      _environment == AppEnvironment.production ||
      _environment == AppEnvironment.pro;

  static bool get isDebug => kDebugMode;

  static bool get isRelease => kReleaseMode;

  static bool get isProfile => kProfileMode;

  static String get apiKey =>
      const String.fromEnvironment('APP_URL', defaultValue: 'app-url');
}

extension _EnvProperties on AppEnvironment {
  static const _appTitles = {
    AppEnvironment.development: 'Dicoding Story - Development',
    AppEnvironment.production: 'Dicoding Story',
  };

  static const _envs = {
    AppEnvironment.development: 'development',
    AppEnvironment.production: 'production',
  };

  String get _appTitle => _appTitles[this]!;

  String get _env => _envs[this]!;
}
