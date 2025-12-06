import 'dart:async';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/common/globals.dart';
import 'package:dicoding_story/data/data_providers.dart';
import 'package:dicoding_story/data/services/local/shared_prefs_storage_service.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockStorageService extends Mock implements SharedPrefsService {}

void main() {
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
    // Stub init() as it is called by storageServiceProvider
    when(() => mockStorageService.init()).thenReturn(null);
    when(() => mockStorageService.get(any())).thenAnswer((_) async => null);
    when(
      () => mockStorageService.set(any(), any()),
    ).thenAnswer((_) async => true);
  });

  group('SettingsDialog', () {
    testWidgets('renders loading state correctly', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // We can trigger loading by using a completer that hasn't completed
      final userCompleter = Completer<String?>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) => userCompleter.future),
            versionProvider.overrideWith((ref) => Future.value('1.0.0+1')),
            storageServiceProvider.overrideWithValue(mockStorageService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialog(),
          ),
        ),
      );
    });

    testWidgets('renders user data and version correctly', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) async => 'Test User'),
            versionProvider.overrideWith((ref) async => '1.0.0+1'),
            storageServiceProvider.overrideWithValue(mockStorageService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialog(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Halo, Test User'), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // Initial
      expect(find.textContaining('1.0.0+1'), findsOneWidget);
    });

    testWidgets('renders default user and version loading', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Use Completer to simulate ongoing loading without timers
      final userCompleter = Completer<String?>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) => userCompleter.future),
            versionProvider.overrideWith(
              (ref) async => '...',
            ), // Loading version
            storageServiceProvider.overrideWithValue(mockStorageService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialog(),
          ),
        ),
      );

      // Should be loading or default
      expect(find.text('Halo, ...'), findsOneWidget);
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      ); // Avatar loading
    });

    testWidgets('renders user error state', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) => Future.error('Failed')),
            versionProvider.overrideWith((ref) async => '1.0.0'),
            storageServiceProvider.overrideWithValue(mockStorageService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialog(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Halo, User'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('changes theme', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) async => 'User'),
            versionProvider.overrideWith((ref) async => '1.0.0'),
            storageServiceProvider.overrideWithValue(mockStorageService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Dropdown
      final dropdownFinder = find.byKey(const Key('theme_dropdown'));
      expect(dropdownFinder, findsOneWidget);

      // Open Dropdown
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select Dark (EN string)
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      // Verify storage called
      verify(
        () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'dark'),
      ).called(1);
    });

    testWidgets('changes language', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) async => 'User'),
            versionProvider.overrideWith((ref) async => '1.0.0'),
            storageServiceProvider.overrideWithValue(mockStorageService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Language option
      final languageOption = find.byKey(const Key('language'));
      expect(languageOption, findsOneWidget);

      // Tap it
      await tester.tap(languageOption);
      await tester.pumpAndSettle();

      // Dialog appears (EN string)
      expect(find.text('Select Language'), findsOneWidget);

      // Select Indonesia (EN string for 'id'?)
      // Check app_en.arb: "settingsBtnLanguageID": "Indonesian"
      await tester.tap(find.text('Indonesian'));
      await tester.pumpAndSettle(); // Radio change

      // Verify storage called
      verify(
        () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'id'),
      ).called(1);

      // Verify dialog closed
      expect(find.text('Select Language'), findsNothing);
    });

    testWidgets('logout triggers provider and navigation', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsDialog(),
          ),
          GoRoute(
            name: 'login',
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchUserDataProvider.overrideWith((ref) async => 'User'),
            versionProvider.overrideWith((ref) async => '1.0.0'),
            storageServiceProvider.overrideWithValue(mockStorageService),
            logoutProvider.overrideWith((ref) async => true),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logoutBtn = find.byKey(const ValueKey('logoutButton'));
      expect(logoutBtn, findsOneWidget);

      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Should have navigated to login
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
