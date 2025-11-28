import 'dart:io' show Platform;

import 'package:dicoding_story/common/app_router.dart';
import 'package:dicoding_story/common/theme.dart';
import 'package:dicoding_story/common/util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
      await windowManager.setMinimumSize(const Size(480, 640));
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
      )
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
  _setupDesktopWindow();
  _setupSystemUI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Quicksand", "Quicksand");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(name: MOBILE, start: 0, end: 450),
          const Breakpoint(name: TABLET, start: 451, end: 800),
          const Breakpoint(name: DESKTOP, start: 801, end: 1920),
          const Breakpoint(name: '4K', start: 1921, end: double.infinity),
        ],
      ),
      routerConfig: AppRouter.createRouter(),
      title: 'KodaKito',
      // theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      theme: theme.light(),
      darkTheme: theme.dark(),
    );
  }
}
