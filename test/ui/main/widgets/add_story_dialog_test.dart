import 'dart:io';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/main/widgets/add_story_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

class MockListRepository extends Mock implements ListRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channelImagePicker = MethodChannel(
    'plugins.flutter.io/image_picker',
  );

  late MockAddStoryRepository mockAddStoryRepository;
  late MockListRepository mockListRepository;
  String? mockPickedImagePath;

  setUpAll(() async {
    registerFallbackValue(File('dummy'));
  });

  setUp(() {
    mockAddStoryRepository = MockAddStoryRepository();
    mockListRepository = MockListRepository();
    mockPickedImagePath = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelImagePicker, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'pickImage') {
            return mockPickedImagePath;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelImagePicker, null);
  });

  Future<void> pumpTestWidget(
    WidgetTester tester, {
    required ProviderContainer container,
    required Widget child,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AddStoryDialog', () {
    testWidgets('renders all initial elements correctly', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      expect(find.text('Add Story'), findsOneWidget);
      expect(find.text('Story Photo'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Post'), findsOneWidget);
    });

    testWidgets('shows error if description is empty', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a description'), findsOneWidget);
    });

    testWidgets('shows error if image is empty', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      await tester.enterText(find.byType(TextField), 'Test Description');
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(find.text('Please select an image'), findsOneWidget);
    });
  });
}
