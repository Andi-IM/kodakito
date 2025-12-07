import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
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
      expect(state, const StoriesState.initial());
    });

    test('fetchStories success updates state to loaded', () async {
      // Arrange
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => Right(tStories));

      container.listen(
        storiesProvider,
        storiesListener.call,
        fireImmediately: true,
      );

      // Act
      // Trigger fetchStories by reading the provider (it runs in build)
      // or calling it manually if we want to test the method specifically.
      // Since it runs in build via microtask, we might need to wait.
      // However, to test the logic deterministically, we can call the method manually.
      await container.read(storiesProvider.notifier).fetchStories();

      // Assert
      verifyInOrder([
        () => storiesListener(null, const StoriesState.initial()),
        () => storiesListener(
          const StoriesState.initial(),
          const StoriesState(state: StoriesConcreteState.loading),
        ),
        () => storiesListener(
          const StoriesState(state: StoriesConcreteState.loading),
          StoriesState(state: StoriesConcreteState.loaded, stories: tStories),
        ),
      ]);
      verify(() => mockListRepository.getListStories()).called(1);
    });

    test('fetchStories failure updates state to failure', () async {
      // Arrange
      final exception = AppException(
        message: 'Fetch failed',
        statusCode: 500,
        identifier: 'fetch',
      );
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => Left(exception));

      container.listen(
        storiesProvider,
        storiesListener.call,
        fireImmediately: true,
      );

      // Act
      await container.read(storiesProvider.notifier).fetchStories();

      // Assert
      verifyInOrder([
        () => storiesListener(null, const StoriesState.initial()),
        () => storiesListener(
          const StoriesState.initial(),
          const StoriesState(state: StoriesConcreteState.loading),
        ),
        () => storiesListener(
          const StoriesState(state: StoriesConcreteState.loading),
          StoriesState(
            state: StoriesConcreteState.failure,
            message: exception.message,
          ),
        ),
      ]);
      verify(() => mockListRepository.getListStories()).called(1);
    });

    test('resetState resets state to initial', () {
      // Arrange
      // Set some state first
      container.read(storiesProvider.notifier).resetState();

      final state = container.read(storiesProvider);
      expect(state, const StoriesState.initial());
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
}

class MockListRepository extends Mock implements ListRepository {}

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

class MockXFile extends Mock implements XFile {}

class FakeXFile extends Fake implements XFile {}

class MockInstaAssetsExportDetails extends Mock
    implements InstaAssetsExportDetails {}

class MockInstaAssetsExportData extends Mock implements InstaAssetsExportData {}
