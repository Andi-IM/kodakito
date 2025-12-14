import 'package:flutter/foundation.dart';

// coverage:ignore-file
enum AppEnvironment { freeDev, freeProd, paidDev, paidProd }

abstract class EnvInfo {
  static AppEnvironment _environment = AppEnvironment.freeDev;

  static AppEnvironment get environment => _environment;

  static void initialize(AppEnvironment environment) {
    EnvInfo._environment = environment;
  }

  static String get appName => _environment._appTitle;

  static String get env => _environment._env;

  static bool get isProduction =>
      _environment == AppEnvironment.freeProd ||
      _environment == AppEnvironment.paidProd;

  static bool get isDebug => kDebugMode;

  static bool get isRelease => kReleaseMode;

  static bool get isProfile => kProfileMode;

  static String get apiKey =>
      const String.fromEnvironment('APP_URL', defaultValue: 'app-url');
}

extension _EnvProperties on AppEnvironment {
  static const _appTitles = {
    AppEnvironment.freeDev: 'Dicoding Story - Development',
    AppEnvironment.freeProd: 'Dicoding Story',
  };

  static const _envs = {
    AppEnvironment.freeDev: 'development',
    AppEnvironment.freeProd: 'production',
  };

  String get _appTitle => _appTitles[this]!;

  String get _env => _envs[this]!;
}
