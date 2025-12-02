import 'package:dicoding_story/common/app_router.dart';
import 'package:dicoding_story/common/theme.dart';
import 'package:dicoding_story/common/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:m3e_collection/m3e_collection.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = createTextTheme(context, "Quicksand", "Quicksand");

    MaterialTheme theme = MaterialTheme(textTheme);
    final themeMode = ref.watch(appThemeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.createRouter(),
      title: 'KodaKito',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: withM3ETheme(theme.light()),
      darkTheme: withM3ETheme(theme.dark()),
      themeMode: themeMode,
    );
  }
}
