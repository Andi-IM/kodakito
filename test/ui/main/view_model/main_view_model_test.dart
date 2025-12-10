import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/app/package_info_service.dart';
import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockListRepository mockListRepository;
  late MockAddStoryRepository mockAddStoryRepository;
  late Listener<StoriesState> storiesListener;

  const MethodChannel channelPathProvider = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUp(() {
    mockListRepository = MockListRepository();
    mockAddStoryRepository = MockAddStoryRepository();
    storiesListener = Listener<StoriesState>();
    registerFallbackValue(FakeXFile());

    container = ProviderContainer(
      overrides: [
        listRepositoryProvider.overrideWithValue(mockListRepository),
        addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
        webPlatformProvider.overrideWithValue(false),
      ],
    );

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
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, null);
  });

  group('ImageFile', () {
    test('initial state is null', () {
      final state = container.read(imageFileProvider);
      expect(state, null);
    });

    test('setImageFile updates state', () {
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      container.read(imageFileProvider.notifier).setImageFile(imageBytes);

      final state = container.read(imageFileProvider);
      expect(state, imageBytes);
    });

    test('toFile returns null when state is null', () async {
      final file = await container.read(imageFileProvider.notifier).toFile();
      expect(file, isNull);
    });

    test('toFile writes bytes to file and returns XFile', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      container.read(imageFileProvider.notifier).setImageFile(imageBytes);

      final file = await container.read(imageFileProvider.notifier).toFile();

      expect(file, isNotNull);
      expect(file!.path, contains('story_'));
      expect(file.path, contains('.jpg'));

      // Clean up created file if it exists
      final actualFile = File(file.path);
      if (actualFile.existsSync()) {
        actualFile.deleteSync();
      }
    });

    test('toFile returns XFile.fromData when on web platform', () async {
      // Create container with web platform override
      final webContainer = ProviderContainer(
        overrides: [
          listRepositoryProvider.overrideWithValue(mockListRepository),
          addStoryRepositoryProvider.overrideWithValue(mockAddStoryRepository),
          webPlatformProvider.overrideWithValue(true),
        ],
      );

      final imageBytes = Uint8List.fromList([1, 2, 3]);
      webContainer.read(imageFileProvider.notifier).setImageFile(imageBytes);

      final file = await webContainer.read(imageFileProvider.notifier).toFile();

      expect(file, isNotNull);
      // XFile.fromData creates an in-memory file, verify bytes are readable
      final bytes = await file!.readAsBytes();
      expect(bytes, imageBytes);

      webContainer.dispose();
    });
  });

  group('getCroppedImageFromPicker', () {
    test('returns null when stream is empty', () async {
      final streamController = StreamController<InstaAssetsExportDetails>();
      final future = container.read(
        getCroppedImageFromPickerProvider(streamController.stream).future,
      );

      streamController.close();

      final result = await future;
      expect(result, isNull);
    });

    test('returns file when stream emits data', () async {
      final streamController = StreamController<InstaAssetsExportDetails>();
      final tFile = File('test_path');

      final mockDetails = MockInstaAssetsExportDetails();
      final mockData = MockInstaAssetsExportData();

      when(() => mockData.croppedFile).thenReturn(tFile);
      when(() => mockDetails.data).thenReturn([mockData]);

      final future = container.read(
        getCroppedImageFromPickerProvider(streamController.stream).future,
      );

      streamController.add(mockDetails);
      streamController.close();

      final result = await future;
      expect(result, equals(tFile));
    });
  });

  group('StoriesNotifier', () {
    final tStories = [
      Story(
        id: 'story-1',
        name: 'Story 1',
        description: 'Description 1',
        photoUrl: 'url1',
        createdAt: DateTime.now(),
        lat: 0,
        lon: 0,
      ),
    ];

    test('initial state is StoriesState.initial', () {
      final state = container.read(storiesProvider);
      expect(state, StoriesState.initial());
      expect(state.isInitialLoading, isFalse);
      expect(state.stories, isEmpty);
      expect(state.nextPage, 1);
    });
    test('getStories success updates state correctly', () async {
      // Arrange
      when(
        () => mockListRepository.getListStories(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => Right(tStories));

      container.listen(
        storiesProvider,
        storiesListener.call,
        fireImmediately: true,
      );

      // Act
      await container.read(storiesProvider.notifier).getStories();

      // Check final state
      final finalState = container.read(storiesProvider);
      expect(finalState.stories, tStories);
      expect(finalState.isInitialLoading, isFalse);
      expect(finalState.isLoadingMore, isFalse);
      expect(finalState.hasError, isFalse);

      verify(
        () => mockListRepository.getListStories(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).called(1);
    });

    test('getStories failure updates state with error', () async {
      // Arrange
      final exception = AppException(
        message: 'Fetch failed',
        statusCode: 500,
        identifier: 'fetch',
      );
      when(
        () => mockListRepository.getListStories(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => Left(exception));

      container.listen(
        storiesProvider,
        storiesListener.call,
        fireImmediately: true,
      );

      // Act
      await container.read(storiesProvider.notifier).getStories();

      // Assert
      final finalState = container.read(storiesProvider);
      expect(finalState.hasError, isTrue);
      expect(finalState.errorMessage, exception.message);

      verify(
        () => mockListRepository.getListStories(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).called(1);
    });

    test('getStories sets nextPage to null when no more items', () async {
      // Arrange - return less than sizeItems (10)
      when(
        () => mockListRepository.getListStories(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => Right(tStories)); // Only 1 story < 10

      // Act
      await container.read(storiesProvider.notifier).getStories();

      // Assert
      final finalState = container.read(storiesProvider);
      expect(finalState.nextPage, isNull); // No more pages
    });

    test('resetState resets state to initial', () {
      // Arrange
      // Set some state first
      container.read(storiesProvider.notifier).resetState();

      final state = container.read(storiesProvider);
      expect(state, StoriesState.initial());
    });
  });

  group('AddStoryNotifier', () {
    final tFile = MockXFile();
    const tDescription = 'Test Description';
    const tLat = 10.0;
    const tLon = 10.0;
    final tResponse = DefaultResponse(error: false, message: 'Success');

    test('initial state is AddStoryInitial', () {
      final state = container.read(addStoryProvider);
      expect(state, isA<AddStoryInitial>());
    });

    test('addStory success updates state to success', () async {
      // Arrange
      when(
        () => mockAddStoryRepository.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer((_) async => Right(tResponse));

      final states = <AddStoryState>[];
      container.listen(addStoryProvider, (previous, next) {
        states.add(next);
      }, fireImmediately: true);

      // Act
      await container
          .read(addStoryProvider.notifier)
          .addStory(
            description: tDescription,
            photoFile: tFile,
            lat: tLat,
            lon: tLon,
          );

      // Assert
      expect(states.length, 3);
      expect(states[0], isA<AddStoryInitial>());
      expect(states[1], isA<AddStoryLoading>());
      expect(states[2], isA<AddStorySuccess>());

      verify(
        () => mockAddStoryRepository.addStory(
          tDescription,
          tFile,
          lat: tLat,
          lon: tLon,
        ),
      ).called(1);
    });

    test('addStory failure updates state to failure', () async {
      // Arrange
      final exception = AppException(
        message: 'Add failed',
        statusCode: 500,
        identifier: 'add',
      );
      when(
        () => mockAddStoryRepository.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer((_) async => Left(exception));

      final states = <AddStoryState>[];
      container.listen(addStoryProvider, (previous, next) {
        states.add(next);
      }, fireImmediately: true);

      // Act
      await container
          .read(addStoryProvider.notifier)
          .addStory(
            description: tDescription,
            photoFile: tFile,
            lat: tLat,
            lon: tLon,
          );

      // Assert
      expect(states.length, 3);
      expect(states[0], isA<AddStoryInitial>());
      expect(states[1], isA<AddStoryLoading>());
      expect(states[2], isA<AddStoryFailure>());
      expect((states[2] as AddStoryFailure).exception, exception);

      verify(
        () => mockAddStoryRepository.addStory(
          tDescription,
          tFile,
          lat: tLat,
          lon: tLon,
        ),
      ).called(1);
    });

    test('resetState resets state to initial', () {
      // Arrange
      // Set some state first
      container.read(addStoryProvider.notifier).resetState();

      final state = container.read(addStoryProvider);
      expect(state, isA<AddStoryInitial>());
    });
  });

  group('versionProvider', () {
    test('returns correct version string', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Dicoding Story',
        packageName: 'com.dicoding.story',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      final String version = await container.read(versionProvider.future);
      expect(version, '1.0.0+1');
    });
  });

  group('overrideWithValue', () {
    group('imageFileProvider', () {
      test(
        'overrideWith allows providing custom initial state via build()',
        () {
          final testBytes = Uint8List.fromList([10, 20, 30]);

          final testContainer = ProviderContainer(
            overrides: [
              imageFileProvider.overrideWith(
                () => TestableImageFile(testBytes),
              ),
            ],
          );
          addTearDown(testContainer.dispose);

          final state = testContainer.read(imageFileProvider);
          expect(state, testBytes);
        },
      );

      test('overrideWith with null initial state', () {
        final testContainer = ProviderContainer(
          overrides: [
            imageFileProvider.overrideWith(() => TestableImageFile(null)),
          ],
        );
        addTearDown(testContainer.dispose);

        final state = testContainer.read(imageFileProvider);
        expect(state, isNull);
      });

      test('overrideWith notifier methods work correctly', () async {
        final testContainer = ProviderContainer(
          overrides: [
            listRepositoryProvider.overrideWithValue(mockListRepository),
            addStoryRepositoryProvider.overrideWithValue(
              mockAddStoryRepository,
            ),
            webPlatformProvider.overrideWithValue(
              true,
            ), // Use web for XFile.fromData
          ],
        );
        addTearDown(testContainer.dispose);

        final imageBytes = Uint8List.fromList([1, 2, 3]);
        testContainer.read(imageFileProvider.notifier).setImageFile(imageBytes);

        final file = await testContainer
            .read(imageFileProvider.notifier)
            .toFile();

        expect(file, isNotNull);
        final bytes = await file!.readAsBytes();
        expect(bytes, imageBytes);
      });
    });

    group('storiesProvider', () {
      test('overrideWith MockStories allows setting loaded state', () {
        final mockStories = MockStories();

        final testContainer = ProviderContainer(
          overrides: [storiesProvider.overrideWith(() => mockStories)],
        );
        addTearDown(testContainer.dispose);

        // Read to initialize the notifier first
        testContainer.read(storiesProvider);

        // Now set the desired state with stories loaded
        mockStories.setState(
          StoriesState(
            stories: [
              Story(
                id: 'test-1',
                name: 'Test Story',
                description: 'Test Description',
                photoUrl: 'https://test.com/photo.jpg',
                createdAt: DateTime(2024, 1, 1),
                lat: 0,
                lon: 0,
              ),
            ],
            isInitialLoading: false,
            isLoadingMore: false,
            hasError: false,
            errorMessage: null,
            nextPage: 2,
            sizeItems: 10,
          ),
        );

        final state = testContainer.read(storiesProvider);
        expect(state.isInitialLoading, isFalse);
        expect(state.stories.length, 1);
        expect(state.stories.first.id, 'test-1');
      });

      test('overrideWith MockStories with loading state', () {
        final mockStories = MockStories();

        final testContainer = ProviderContainer(
          overrides: [storiesProvider.overrideWith(() => mockStories)],
        );
        addTearDown(testContainer.dispose);

        // Read to initialize the notifier first
        testContainer.read(storiesProvider);

        mockStories.setState(
          StoriesState.initial().copyWith(isInitialLoading: true),
        );

        final state = testContainer.read(storiesProvider);
        expect(state.isInitialLoading, isTrue);
        expect(state.stories, isEmpty);
      });

      test('overrideWith MockStories with error state', () {
        final mockStories = MockStories();

        final testContainer = ProviderContainer(
          overrides: [storiesProvider.overrideWith(() => mockStories)],
        );
        addTearDown(testContainer.dispose);

        // Read to initialize the notifier first
        testContainer.read(storiesProvider);

        mockStories.setState(
          StoriesState.initial().copyWith(
            hasError: true,
            errorMessage: 'Test error message',
            isInitialLoading: false,
          ),
        );

        final state = testContainer.read(storiesProvider);
        expect(state.hasError, isTrue);
        expect(state.errorMessage, 'Test error message');
      });

      test('overrideWith MockStories setState updates state correctly', () {
        final mockStories = MockStories();

        final testContainer = ProviderContainer(
          overrides: [storiesProvider.overrideWith(() => mockStories)],
        );
        addTearDown(testContainer.dispose);

        // Initial state from build()
        expect(testContainer.read(storiesProvider), StoriesState.initial());

        // Update state via setState
        mockStories.setState(
          StoriesState.initial().copyWith(isInitialLoading: false, stories: []),
        );

        // Read updated state
        final state = testContainer.read(storiesProvider);
        expect(state.isInitialLoading, isFalse);
        expect(state.stories, isEmpty);
      });
    });

    group('addStoryProvider', () {
      test('overrideWith allows providing custom initial state', () {
        final testContainer = ProviderContainer(
          overrides: [
            addStoryProvider.overrideWith(
              () => TestableAddStoryNotifier(const AddStoryInitial()),
            ),
          ],
        );
        addTearDown(testContainer.dispose);

        final state = testContainer.read(addStoryProvider);
        expect(state, isA<AddStoryInitial>());
      });

      test('overrideWith with loading state', () {
        final testContainer = ProviderContainer(
          overrides: [
            addStoryProvider.overrideWith(
              () => TestableAddStoryNotifier(const AddStoryLoading()),
            ),
          ],
        );
        addTearDown(testContainer.dispose);

        final state = testContainer.read(addStoryProvider);
        expect(state, isA<AddStoryLoading>());
      });

      test('overrideWith with success state', () {
        final testContainer = ProviderContainer(
          overrides: [
            addStoryProvider.overrideWith(
              () => TestableAddStoryNotifier(const AddStorySuccess()),
            ),
          ],
        );
        addTearDown(testContainer.dispose);

        final state = testContainer.read(addStoryProvider);
        expect(state, isA<AddStorySuccess>());
      });

      test('overrideWith with failure state', () {
        final exception = AppException(
          message: 'Override test failure',
          statusCode: 400,
          identifier: 'test',
        );

        final testContainer = ProviderContainer(
          overrides: [
            addStoryProvider.overrideWith(
              () => TestableAddStoryNotifier(AddStoryFailure(exception)),
            ),
          ],
        );
        addTearDown(testContainer.dispose);

        final state = testContainer.read(addStoryProvider);
        expect(state, isA<AddStoryFailure>());
        expect(
          (state as AddStoryFailure).exception.message,
          'Override test failure',
        );
      });

      test('overrideWith testable notifier can update state', () {
        final testableNotifier = TestableAddStoryNotifier(
          const AddStoryInitial(),
        );

        final testContainer = ProviderContainer(
          overrides: [addStoryProvider.overrideWith(() => testableNotifier)],
        );
        addTearDown(testContainer.dispose);

        // Initial state
        expect(testContainer.read(addStoryProvider), isA<AddStoryInitial>());

        // Update state via testable notifier
        testableNotifier.setTestState(const AddStoryLoading());
        expect(testContainer.read(addStoryProvider), isA<AddStoryLoading>());

        // Update to success
        testableNotifier.setTestState(const AddStorySuccess());
        expect(testContainer.read(addStoryProvider), isA<AddStorySuccess>());
      });
    });
  });
}

/// Testable ImageFile notifier that allows custom initial state
class TestableImageFile extends ImageFile {
  final Uint8List? _initialState;

  TestableImageFile(this._initialState);

  @override
  Uint8List? build() => _initialState;
}

/// Testable AddStoryNotifier that allows custom initial state and state updates
class TestableAddStoryNotifier extends AddStoryNotifier {
  final AddStoryState _initialState;

  TestableAddStoryNotifier(this._initialState);

  @override
  AddStoryState build() => _initialState;

  void setTestState(AddStoryState newState) {
    state = newState;
  }
}

class MockListRepository extends Mock implements ListRepository {}

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

class MockXFile extends Mock implements XFile {}

class FakeXFile extends Fake implements XFile {}

class MockInstaAssetsExportDetails extends Mock
    implements InstaAssetsExportDetails {}

class MockInstaAssetsExportData extends Mock implements InstaAssetsExportData {}
