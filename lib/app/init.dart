import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'app_env.dart';

final logger = Logger('DEBUGLogger');

Future<void> initApp(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvInfo.initialize(environment);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final List<Future<void>> startupFutures = [];

  // Platform.environment is not available on web
  if (kIsWeb) {
    startupFutures.add(dotenv.load(fileName: ".env"));
  } else {
    startupFutures.add(
      dotenv.load(fileName: ".env", mergeWith: Platform.environment),
    );
  }
  startupFutures.add(SharedPreferences.getInstance());

  if (!kIsWeb && Platform.isWindows) {
    startupFutures.add(() async {
      await windowManager.ensureInitialized();
      final options = WindowOptions();
      await windowManager.waitUntilReadyToShow(options, () async {
        await windowManager.setMinimumSize(const Size(450, 640));
        await windowManager.setTitle('KodaKito');
        await windowManager.show();
        await windowManager.focus();
      });
    }());
  }

  if (kIsWeb) {
    usePathUrlStrategy();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  await Future.wait(startupFutures);
}
