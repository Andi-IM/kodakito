import 'package:dicoding_story/common/app_router.dart';
import 'package:dicoding_story/common/theme.dart';
import 'package:dicoding_story/common/util.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
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
    );
  }
}
