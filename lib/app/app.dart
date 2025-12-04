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
    TextTheme textTheme = createTextTheme(context, "Mulish", "Quicksand");

    MaterialTheme theme = MaterialTheme(textTheme);
    final themeMode = ref.watch(appThemeProvider);
    final locale = ref.watch(appLanguageProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      title: 'KodaKito',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: withM3ETheme(theme.light()),
      darkTheme: withM3ETheme(theme.dark()),
      themeMode: themeMode,
    );
  }
}
