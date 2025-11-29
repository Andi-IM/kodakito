import 'dart:io' show Platform;

import 'package:dicoding_story/common/app_router.dart';
import 'package:dicoding_story/common/theme.dart';
import 'package:dicoding_story/common/util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:window_manager/window_manager.dart';


Future initLogging() async {
  Logger.root.level = Level.ALL;
}

final logger = Logger('DEBUGLogger');

Future<void> _setupDesktopWindow() async {
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
}

Future<void> _setupSystemUI() async {
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
}

void main() {
  initLogging();
  WidgetsFlutterBinding.ensureInitialized();
  _setupDesktopWindow();
  _setupSystemUI();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Quicksand", "Quicksand");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      routerConfig: AppRouter.createRouter(),
      title: 'KodaKito',
      // theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      theme: withM3ETheme(theme.light()),
      darkTheme: withM3ETheme(theme.dark()),
      themeMode: ThemeMode.light,
    );
  }
}
