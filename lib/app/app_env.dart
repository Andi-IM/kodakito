import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_env.g.dart';

@riverpod
EnvInfo envInfo(Ref ref) {
  final env = dotenv.get("APP_ENV", fallback: "development");
  final appEnvironment = switch (env) {
    "production" => AppEnvironment.production,
    "proDevelopment" => AppEnvironment.proDevelopment,
    "pro" => AppEnvironment.pro,
    _ => AppEnvironment.development,
  };
  return EnvInfo(appEnvironment);
}

enum AppEnvironment { development, production, proDevelopment, pro }

class EnvInfo {
  final AppEnvironment environment;

  const EnvInfo(this.environment);

  String get appName => environment._appTitle;

  String get env => environment._env;

  bool get isProduction => environment == AppEnvironment.production;

  bool get isDebug => kDebugMode;

  bool get isRelease => kReleaseMode;

  bool get isProfile => kProfileMode;


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
