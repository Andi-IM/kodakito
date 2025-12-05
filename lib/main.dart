import 'dart:io' show Platform;
import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/app/observer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final logger = Logger('DEBUGLogger');

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final String environment = dotenv.get("APP_ENV");
  final AppEnvironment env = (environment == "prod") ? AppEnvironment.production : AppEnvironment.development;

  mainCommon(env);
}

Future<void> mainCommon(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvInfo.initialize(environment);
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  usePathUrlStrategy();

  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    final options = WindowOptions();
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setMinimumSize(const Size(450, 640));
      await windowManager.setTitle('KodaKito');
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(ProviderScope(observers: [Observer()], child: MyApp()));
}
