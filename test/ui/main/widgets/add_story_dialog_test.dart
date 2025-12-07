import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_dialog.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

class MockListRepository extends Mock implements ListRepository {}

class SafeImageFile extends ImageFile {
  @override
  Future<File?> toFile() async {
    // Return a dummy file directly without file IO
    return File('dummy_image.jpg');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channelImagePicker = MethodChannel(
    'plugins.flutter.io/image_picker',
  );
  // We keep path_provider mock just in case other parts invoke it
  const MethodChannel channelPathProvider = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  late MockAddStoryRepository mockAddStoryRepository;
  late MockListRepository mockListRepository;
  String? mockPickedImagePath;

  setUpAll(() async {
    registerFallbackValue(File('dummy'));
  });

  setUp(() async {
    mockAddStoryRepository = MockAddStoryRepository();
    mockListRepository = MockListRepository();

    // Create a dummy image file for readAsBytes to suffice
    final file = File('dummy_image.jpg');
    // Minimal valid JPG header or just random bytes might be enough
    // if we don't test Crop widget that requires valid image.
    // If we skip the Crop test, random bytes is fine for XFile.
    // SafeImageFile is used in other tests.
    await file.writeAsBytes([1, 2, 3]);
    mockPickedImagePath = file.absolute.path;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelImagePicker, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'pickImage') {
            return mockPickedImagePath;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getTemporaryDirectory') {
            return '.';
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelImagePicker, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, null);

    final file = File('dummy_image.jpg');
    if (file.existsSync()) {
      file.deleteSync();
    }
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
          // Use SafeImageFile to avoid file IO issues
          imageFileProvider.overrideWith(() => SafeImageFile()),
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
          imageFileProvider.overrideWith(() => SafeImageFile()),
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
          imageFileProvider.overrideWith(() => SafeImageFile()),
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

    // Skipped crop test to avoid complexity with external widget dependencies in test env.

    testWidgets('posts story successfully', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Setup repository responses
      when(() => mockAddStoryRepository.addStory(any(), any())).thenAnswer(
        (_) async => const Right(
          DefaultResponse(error: false, message: 'Story Created Successfully'),
        ),
      );
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => const Right([]));

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          imageFileProvider.overrideWith(() => SafeImageFile()),
        ],
      );
      addTearDown(container.dispose);

      // Seed the image provider
      container
          .read(imageFileProvider.notifier)
          .setImageFile(Uint8List.fromList([1, 2, 3]));

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      // Enter description
      await tester.enterText(find.byType(TextField), 'My New Story');
      await tester.pump();

      // Tap Post
      await tester.tap(find.text('Post'));

      // Wait for async operations but dont let snackbar disappear
      await tester.pump(); // Start loading
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Allow async to complete

      // Verify repository call
      verify(
        () => mockAddStoryRepository.addStory('My New Story', any()),
      ).called(1);
      // Verify list refresh
      verify(() => mockListRepository.getListStories()).called(1);

      // Verify success snackbar - check immediately before it fades
      expect(find.text('Story posted successfully!'), findsOneWidget);

      // Now settle everything (snackbar might disappear, dialog closes)
      await tester.pumpAndSettle();

      // Verify dialog is closed (Add Story text title should be gone)
      expect(find.text('Add Story'), findsNothing);
    });

    testWidgets('shows error when posting fails', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Setup repository failure
      when(() => mockAddStoryRepository.addStory(any(), any())).thenAnswer(
        (_) async => Left(
          AppException(
            message: 'Upload Failed',
            statusCode: 500,
            identifier: 'UploadFailed',
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          imageFileProvider.overrideWith(() => SafeImageFile()),
        ],
      );
      addTearDown(container.dispose);

      // Seed the image provider
      container
          .read(imageFileProvider.notifier)
          .setImageFile(Uint8List.fromList([1, 2, 3]));

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      // Enter description
      await tester.enterText(find.byType(TextField), 'My Failed Story');
      await tester.pump();

      // Tap Post
      await tester.tap(find.text('Post'));

      // Pump to process future
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify repository call
      verify(
        () => mockAddStoryRepository.addStory('My Failed Story', any()),
      ).called(1);

      // Verify error snackbar immediately
      expect(find.text('Upload Failed'), findsOneWidget);

      // Verify dialog is still open
      expect(find.text('Add Story'), findsOneWidget);
    });
  });
}
