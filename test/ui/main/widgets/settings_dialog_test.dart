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
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

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

  Future<void> pumpTestWidget(
    WidgetTester tester, {
    required ProviderContainer container,
    bool settle = true,
  }) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const SettingsDialog(),
                      );
                    },
                    child: const Text('Open Settings'),
                  );
                },
              ),
            );
          },
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
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open the dialog
    await tester.tap(find.text('Open Settings'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  group('SettingsDialog', () {
    testWidgets('renders loading state correctly', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final userCompleter = Completer<String?>();
      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) => userCompleter.future),
          versionProvider.overrideWith((ref) => Future.value('1.0.0+1')),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container, settle: false);

      // Should find the loading state (e.g. from the avatar or text placeholder if any)
      // The current implementation shows "Halo, ..." when loading name
      expect(find.text('Halo, ...'), findsOneWidget);
    });

    testWidgets('renders user data and version correctly', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'Test User'),
          versionProvider.overrideWith((ref) async => '1.0.0+1'),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      expect(find.text('Halo, Test User'), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // Initial
      expect(find.textContaining('1.0.0+1'), findsOneWidget);
    });

    testWidgets('renders user error state', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) => Future.error('Failed')),
          versionProvider.overrideWith((ref) async => '1.0.0'),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      expect(find.text('Halo, User'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('changes theme', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'User'),
          versionProvider.overrideWith((ref) async => '1.0.0'),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

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

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'User'),
          versionProvider.overrideWith((ref) async => '1.0.0'),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      // Find Language option
      final languageOption = find.byKey(const Key('language'));
      expect(languageOption, findsOneWidget);

      // Tap it
      await tester.tap(languageOption);
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Select Language'), findsOneWidget);

      // Select Indonesia (EN string for 'id')
      await tester.tap(find.text('Indonesian'));
      await tester.pumpAndSettle();

      // Verify storage called
      verify(
        () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'id'),
      ).called(1);

      // Verify language dialog closed
      expect(find.text('Select Language'), findsNothing);
    });

    testWidgets('logout triggers provider and navigation', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'User'),
          versionProvider.overrideWith((ref) async => '1.0.0'),
          storageServiceProvider.overrideWithValue(mockStorageService),
          logoutProvider.overrideWith((ref) async => true),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      final logoutBtn = find.byKey(const ValueKey('logoutButton'));
      expect(logoutBtn, findsOneWidget);

      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Should have navigated to login
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('closes dialog on close button tap', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'User'),
          versionProvider.overrideWith((ref) async => '1.0.0'),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      // Find Close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      // Tap it
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Verify dialog closed
      expect(find.byType(SettingsDialog), findsNothing);
    });

    testWidgets('renders precise version text', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'Test User'),
          versionProvider.overrideWith(
            (ref) async => '1.2.3+4',
          ), // Specific version
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      // Verify exact version text
      // Assuming l10n.settingsTextVersion is "Version $version" or similar.
      // We will look for the version string directly.
      expect(find.textContaining('1.2.3+4'), findsOneWidget);
    });

    testWidgets('closes language dialog on cancel', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          fetchUserDataProvider.overrideWith((ref) async => 'User'),
          versionProvider.overrideWith((ref) async => '1.0.0'),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(tester, container: container);

      // Open Language Dialog
      await tester.tap(find.byKey(const Key('language')));
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsOneWidget);

      // Tap Cancel
      // In tests, localizations usually default to English values or keys if not mocked differently.
      // Assuming 'Cancel' is the English value for settingsBtnCancel.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsNothing);
    });
  });
}
