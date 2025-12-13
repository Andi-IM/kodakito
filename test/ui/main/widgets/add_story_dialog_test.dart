import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/home/view_model/home_view_model.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/wide/add_story_dialog.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/wide/add_story_image_container.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/wide/story_crop_dialog.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

class MockListRepository extends Mock implements ListRepository {}

class FakeXFile extends Fake implements XFile {}

class SafeImageFile extends ImageFile {
  @override
  Future<XFile?> toFile() async {
    // Return a dummy XFile directly without file IO
    return XFile('dummy_image.jpg');
  }
}

class MockCropController extends Mock implements CropController {}

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

  final validImageBytes = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  setUpAll(() async {
    registerFallbackValue(FakeXFile());
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
    await file.writeAsBytes(validImageBytes);
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

    // Try to delete the file, but ignore errors if it's locked
    try {
      final file = File('dummy_image.jpg');
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {
      // Ignore file lock errors in tearDown
    }
  });

  Future<void> pumpTestWidget(
    WidgetTester tester, {
    required ProviderContainer container,
    required Widget child,
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
                      showDialog(context: context, builder: (context) => child);
                    },
                    child: const Text('Launch Dialog'),
                  );
                },
              ),
            );
          },
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
    await tester.tap(find.text('Launch Dialog'));
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
          webPlatformProvider.overrideWithValue(false),
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

    testWidgets('initializes with a specific key', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          imageFileProvider.overrideWith(() => SafeImageFile()),
          webPlatformProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      const key = Key('specific_dialog_key');
      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(key: key),
      );

      expect(find.byKey(key), findsOneWidget);
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
          webPlatformProvider.overrideWithValue(false),
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
          webPlatformProvider.overrideWithValue(false),
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
          webPlatformProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      // Seed the image provider
      container.read(imageFileProvider.notifier).setImageFile(validImageBytes);
      await tester.pump();

      // Enter description
      await tester.enterText(find.byType(TextField), 'My New Story');
      await tester.pump();

      // Verify dialog is closed (Add Story text title should be gone)
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
          webPlatformProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      // Seed the image provider after dialog is open
      container.read(imageFileProvider.notifier).setImageFile(validImageBytes);
      await tester.pump();

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

    testWidgets('closes dialog on cancel button tap', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          imageFileProvider.overrideWith(() => SafeImageFile()),
          webPlatformProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      // Verify dialog is open
      expect(find.text('Add Story'), findsOneWidget);

      // Find Cancel button (TextButton with 'Cancel' text - l10n default English)
      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);

      // Tap Cancel
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Verify dialog closed
      expect(find.text('Add Story'), findsNothing);
    });

    testWidgets('shows loading indicator on button when posting', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Setup delayed repository response
      when(() => mockAddStoryRepository.addStory(any(), any())).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return const Right(
          DefaultResponse(error: false, message: 'Story Created Successfully'),
        );
      });
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => const Right([]));

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          imageFileProvider.overrideWith(() => SafeImageFile()),
          webPlatformProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      await pumpTestWidget(
        tester,
        container: container,
        child: const AddStoryDialog(),
      );

      // Prepare data
      container.read(imageFileProvider.notifier).setImageFile(validImageBytes);
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Loading Story');
      await tester.pump();

      // Tap Post
      await tester.tap(find.text('Post'));
      // Pump to start the action but not finish it (settle)
      await tester.pump();
      // Pump a bit to let the loading state propagate to UI
      await tester.pump(const Duration(milliseconds: 100));

      // Verify CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Verify Text 'Post' is NOT shown (it should be replaced by spinner)
      expect(find.text('Post'), findsNothing);

      // Finish the async operation
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Verify success finally
      expect(find.text('Story posted successfully!'), findsOneWidget);
    });

    group('AddStoryImageContainer', () {
      testWidgets(
        'pickImage navigates to add-story-crop when getImageFile returns bytes',
        (tester) async {
          tester.view.physicalSize = const Size(1000, 2000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          bool navigationCalled = false;
          Uint8List? navigatedExtra;

          final container = ProviderContainer(
            overrides: [
              imageFileProvider.overrideWith(() => SafeImageFile()),
              webPlatformProvider.overrideWithValue(false),
            ],
          );
          addTearDown(container.dispose);

          final router = GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                name: 'add-story',
                builder: (context, state) {
                  return Scaffold(
                    body: AddStoryImageContainer(
                      key: const ValueKey('addStoryImageContainer'),
                      getImageFile: () async => validImageBytes,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'crop',
                    name: 'add-story-crop',
                    builder: (context, state) {
                      navigationCalled = true;
                      navigatedExtra = state.extra as Uint8List?;
                      return const SizedBox();
                    },
                  ),
                ],
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

          // Tap AddStoryImageContainer to trigger pickImage
          await tester.tap(
            find.byKey(const ValueKey('addStoryImageContainer')),
          );
          await tester.pumpAndSettle();

          // Verify navigation was called with the image bytes
          expect(navigationCalled, isTrue);
          expect(navigatedExtra, equals(validImageBytes));
        },
      );

      testWidgets(
        'pickImage does not navigate when getImageFile returns null',
        (tester) async {
          tester.view.physicalSize = const Size(1000, 2000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          bool navigationCalled = false;

          final container = ProviderContainer(
            overrides: [
              imageFileProvider.overrideWith(() => SafeImageFile()),
              webPlatformProvider.overrideWithValue(false),
            ],
          );
          addTearDown(container.dispose);

          final router = GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                name: 'add-story',
                builder: (context, state) {
                  return Scaffold(
                    body: AddStoryImageContainer(
                      key: const ValueKey('addStoryImageContainer'),
                      getImageFile: () async => null, // Returns null
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'crop',
                    name: 'add-story-crop',
                    builder: (context, state) {
                      navigationCalled = true;
                      return const SizedBox();
                    },
                  ),
                ],
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

          // Tap AddStoryImageContainer to trigger pickImage
          await tester.tap(
            find.byKey(const ValueKey('addStoryImageContainer')),
          );
          await tester.pumpAndSettle();

          // Verify navigation was NOT called
          expect(navigationCalled, isFalse);
        },
      );
    });

    group('StoryCropDialog', () {
      late MockCropController mockCropController;

      setUp(() {
        mockCropController = MockCropController();
      });

      testWidgets('calls crop on controller when Crop button is pressed', (
        tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            imageFileProvider.overrideWith(() => SafeImageFile()),
            webPlatformProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);

        await pumpTestWidget(
          tester,
          container: container,
          child: StoryCropDialog(
            imageBytes: validImageBytes,
            cropController: mockCropController,
          ),
        );

        // Tap Crop button
        await tester.tap(find.text('Crop'));
        await tester.pump();

        verify(() => mockCropController.crop()).called(1);
      });

      testWidgets('calls onPop on Cancel button', (tester) async {
        bool onPopCalled = false;
        final container = ProviderContainer(
          overrides: [
            imageFileProvider.overrideWith(() => SafeImageFile()),
            webPlatformProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);

        await pumpTestWidget(
          tester,
          container: container,
          child: StoryCropDialog(
            imageBytes: validImageBytes,
            cropController: mockCropController,
            onPop: () => onPopCalled = true,
          ),
        );

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify onPop was called
        expect(onPopCalled, isTrue);
      });

      testWidgets('updates image and calls onPop on crop success', (
        tester,
      ) async {
        bool onPopCalled = false;
        final container = ProviderContainer(
          overrides: [
            imageFileProvider.overrideWith(() => SafeImageFile()),
            webPlatformProvider.overrideWithValue(false),
          ],
        );
        addTearDown(container.dispose);

        // Keep provider alive
        container.listen(imageFileProvider, (previous, next) {});

        await pumpTestWidget(
          tester,
          container: container,
          child: StoryCropDialog(
            imageBytes: validImageBytes,
            cropController: mockCropController,
            onPop: () => onPopCalled = true,
          ),
        );

        // Find Crop widget to get callback
        final cropWidgetFinder = find.byType(Crop);
        expect(cropWidgetFinder, findsOneWidget);
        final Crop cropWidget = tester.widget(cropWidgetFinder);

        // Simulate success callback
        final croppedBytes = validImageBytes;
        cropWidget.onCropped(CropSuccess(croppedBytes));

        // Pump to handle state update
        await tester.pumpAndSettle();

        // Verify onPop was called
        expect(onPopCalled, isTrue);

        // Verify provider updated
        final storedImage = container.read(imageFileProvider);
        expect(storedImage, isNotNull);
        expect(storedImage, equals(croppedBytes));
      });
    });
  });
}
