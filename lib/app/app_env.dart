enum AppEnvironment { development, production }

abstract class EnvInfo {
  static AppEnvironment _environment = AppEnvironment.development;

  static void initialize(AppEnvironment env) {
    EnvInfo._environment = env;
  }

  static String get appName => _environment._appTitle;
  static String get env => _environment._env;
  static AppEnvironment get environment => _environment;
  static bool get isProduction => _environment == AppEnvironment.production;
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
