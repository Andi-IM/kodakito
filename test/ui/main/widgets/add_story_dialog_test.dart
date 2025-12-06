import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story_dialog.dart';
import 'package:dicoding_story/utils/http_exception.dart';
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

  late Uint8List testImageBytes;

  setUpAll(() async {
    registerFallbackValue(File('dummy'));

    // Use a minimal valid 1x1 transparent PNG (base64 decoded)
    // This ensures image format validation passes in tests
    testImageBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );
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

    test('successful story post - provider logic', () async {
      // This tests the provider logic directly instead of through UI
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      // Create a test file
      final testFile = File(
        '${Directory.systemTemp.path}/test_story_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await testFile.writeAsBytes(testImageBytes);

      // Don't auto-delete in addTearDown as the file may be in use
      // We'll let the OS clean up temp files

      // Mock success response
      when(
        () => mockAddStoryRepository.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer(
        (_) async => Right(DefaultResponse(error: false, message: 'Success')),
      );

      // Stub list refresh
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => const Right<AppException, List<Story>>([]));

      // Call addStory directly through provider
      await container
          .read(addStoryProvider.notifier)
          .addStory(description: 'Great Story', photo: testFile);

      // Verify addStory was called with correct parameters
      verify(
        () => mockAddStoryRepository.addStory(
          'Great Story',
          any(that: isA<File>()),
        ),
      ).called(1);

      // Verify list refresh was triggered
      verify(() => mockListRepository.getListStories()).called(1);
    });

    testWidgets('failed story post shows error', (tester) async {
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

      // Set image
      container.read(imageFileProvider.notifier).setImageFile(testImageBytes);
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(find.byType(TextField), 'Fail Story');

      // Mock Failure
      when(
        () => mockAddStoryRepository.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer(
        (_) async => Left(
          AppException(
            message: 'Upload failed',
            statusCode: 500,
            identifier: 'test',
          ),
        ),
      );

      // Tap Post
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      // Verify Snackbar or error message
      expect(find.text('Upload failed'), findsOneWidget);
    });

    testWidgets('shows loading state while posting', (tester) async {
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

      container.read(imageFileProvider.notifier).setImageFile(testImageBytes);
      await tester.enterText(find.byType(TextField), 'Loading Story');
      await tester.pumpAndSettle();

      // Mock delayed response
      final completer = Completer<Either<AppException, DefaultResponse>>();
      when(
        () => mockAddStoryRepository.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer((_) => completer.future);

      // Tap Post
      await tester.tap(find.text('Post'));
      await tester.pump(); // Start request

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Finish
      completer.complete(Right(DefaultResponse(error: false, message: 'Done')));

      // Stub for the refresh
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => const Right<AppException, List<Story>>([]));

      await tester.pumpAndSettle();
    });
  });
}
