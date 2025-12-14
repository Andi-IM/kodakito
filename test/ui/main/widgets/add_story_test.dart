import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/home/view_model/home_view_model.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/compact/add_story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:mocktail/mocktail.dart';

class MockInstaAssetsExportDetails extends Mock
    implements InstaAssetsExportDetails {}

class MockInstaAssetsExportData extends Mock implements InstaAssetsExportData {}

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

class MockListRepository extends Mock implements ListRepository {}

class MockSelectedLocation extends SelectedLocation {
  @override
  PlaceInfo? build() => PlaceInfo(
    formattedAddress: 'Test Address',
    street: 'Test Street',
    locality: 'Test Locality',
    city: 'Jakarta',
    state: 'DKI Jakarta',
    country: 'Indonesia',
    postalCode: '12345',
    latitude: -6.2,
    longitude: 106.8,
  );
}

class FakeXFile extends Fake implements XFile {}

void main() {
  late StreamController<InstaAssetsExportDetails> streamController;
  late MockInstaAssetsExportDetails mockDetails;
  late MockInstaAssetsExportData mockData;
  late MockAddStoryRepository mockRepository;
  late MockListRepository mockListRepository;
  late File testFile;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    testFile = File('${tempDir.path}/test_image.png');
    await testFile.create();
    registerFallbackValue(FakeXFile()); // For repository calls
    EnvInfo.initialize(AppEnvironment.paidProd);
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    streamController = StreamController<InstaAssetsExportDetails>.broadcast();
    mockDetails = MockInstaAssetsExportDetails();
    mockData = MockInstaAssetsExportData();
    mockRepository = MockAddStoryRepository();
    mockListRepository = MockListRepository();

    // Mock listRepository.getListStories to prevent pending timers after success
    when(
      () => mockListRepository.getListStories(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => const Right([]));
  });

  tearDown(() {
    streamController.close();
  });

  Widget createWidgetUnderTest({
    required ProviderContainer container,
    Function()? onSuccess,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddStoryPage(
          cropStream: streamController.stream,
          onAddStorySuccess: onSuccess,
        ),
      ),
    );
  }

  // Helper to prevent 'Bad state: No element' from firstWhere in initState
  Future<void> satisfyFirstWhere(WidgetTester tester) async {
    if (streamController.hasListener && !streamController.isClosed) {
      when(() => mockData.croppedFile).thenReturn(testFile);
      when(() => mockDetails.data).thenReturn([mockData]);
      streamController.add(mockDetails);
      await tester.pump();
    }
  }

  group('AddStoryPage UI Tests', () {
    testWidgets('renders initial state correctly with no data', (tester) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Add Story'), findsOneWidget);
      expect(find.text('Post'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Cleanup to prevent firstWhere exception
      await satisfyFirstWhere(tester);
    });

    testWidgets('renders image when stream emits data', (tester) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);

        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      expect(find.byIcon(Icons.image), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows placeholder if stream emits empty data', (tester) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        when(() => mockDetails.data).thenReturn([]);

        streamController.add(mockDetails);
        await tester.pump();
      });
      await tester.pump();

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      // Cleanup
      await satisfyFirstWhere(tester);
    });

    testWidgets('text field takes input', (tester) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'This is a test story');
      expect(find.text('This is a test story'), findsOneWidget);

      // Cleanup
      await satisfyFirstWhere(tester);
    });

    testWidgets('post button is disabled when no file is selected', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      final postButton = find.byKey(const Key('postButton'));
      expect(postButton, findsOneWidget);

      // Button exists but should not trigger action without file
      await tester.tap(postButton);
      await tester.pumpAndSettle();

      verifyNever(() => mockRepository.addStory(any(), any()));

      // Cleanup
      await satisfyFirstWhere(tester);
    });
  });

  group('AddStoryPage State Management Tests', () {
    testWidgets('calls addStory when post button is tapped with file', (
      tester,
    ) async {
      when(() => mockRepository.addStory(any(), any())).thenAnswer(
        (_) async => Right(DefaultResponse(error: false, message: 'Success')),
      );

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        // Add image via stream
        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);
        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      // Enter description
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test description',
      );
      await tester.pump();

      // Tap post button
      await tester.tap(find.byKey(const Key('postButton')));
      await tester.pump();

      // Verify repository was called with XFile
      verify(
        () => mockRepository.addStory('Test description', any()),
      ).called(1);
    });

    testWidgets('shows loading state while posting', (tester) async {
      final completer = Completer<Either<AppException, DefaultResponse>>();
      when(
        () => mockRepository.addStory(any(), any()),
      ).thenAnswer((_) => completer.future);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        // Add image via stream
        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);
        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      // Enter description
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test description',
      );
      await tester.pump();

      // Tap post button
      await tester.tap(find.byKey(const Key('postButton')));
      await tester.pump();

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check that text field is disabled
      final textField = tester.widget<TextField>(
        find.byKey(const Key('descriptionField')),
      );
      expect(textField.enabled, isFalse);

      // Complete the request
      completer.complete(
        Right(DefaultResponse(error: false, message: 'Success')),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('calls onAddStorySuccess callback on successful post', (
      tester,
    ) async {
      bool successCalled = false;
      when(() => mockRepository.addStory(any(), any())).thenAnswer(
        (_) async => Right(DefaultResponse(error: false, message: 'Success')),
      );

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            container: container,
            onSuccess: () {
              successCalled = true;
            },
          ),
        );
        await tester.pumpAndSettle();

        // Add image via stream
        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);
        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      // Enter description and post
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test description',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('postButton')));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
    });

    testWidgets('shows error snackbar on failed post', (tester) async {
      final exception = AppException(
        message: 'Failed to post story',
        statusCode: 500,
        identifier: 'add_story',
      );

      when(
        () => mockRepository.addStory(any(), any()),
      ).thenAnswer((_) async => Left(exception));

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        // Add image via stream
        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);
        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      // Enter description and post
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test description',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('postButton')));
      await tester.pumpAndSettle();

      // Verify error snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to post story'), findsOneWidget);

      // Verify the snackbar has red background
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });

    testWidgets('disables post button and text field during loading', (
      tester,
    ) async {
      final completer = Completer<Either<AppException, DefaultResponse>>();
      when(
        () => mockRepository.addStory(any(), any()),
      ).thenAnswer((_) => completer.future);

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        // Add image via stream
        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);
        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      // Enter description
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test description',
      );
      await tester.pump();

      // Tap post button
      await tester.tap(find.byKey(const Key('postButton')));
      await tester.pump();

      // Verify button is disabled (shows loading indicator)
      final postButton = tester.widget<TextButton>(
        find.byKey(const Key('postButton')),
      );
      expect(postButton.onPressed, isNull);

      // Verify text field is disabled
      final textField = tester.widget<TextField>(
        find.byKey(const Key('descriptionField')),
      );
      expect(textField.enabled, isFalse);

      // Complete the request to clean up
      completer.complete(
        Right(DefaultResponse(error: false, message: 'Success')),
      );
      await tester.pumpAndSettle();
      // Note: After success, the widget behavior may change due to onAddStorySuccess callback
      // The post-success UI state is tested in other tests
    });
  });

  group('AddStoryPage Location Tests', () {
    testWidgets('hides location button in development environment', (
      tester,
    ) async {
      final oldEnv = EnvInfo.environment;
      EnvInfo.initialize(AppEnvironment.freeDev);
      addTearDown(() => EnvInfo.initialize(oldEnv));

      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('locationButton')), findsNothing);

      // Cleanup
      await satisfyFirstWhere(tester);
    });

    testWidgets('displays location button initially without location', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Location button should show add location icon and text
      expect(find.byKey(const Key('locationButton')), findsOneWidget);
      expect(find.byIcon(Icons.add_location_alt), findsOneWidget);
      expect(find.text('Add Location'), findsOneWidget);

      // Cleanup
      await satisfyFirstWhere(tester);
    });

    testWidgets('displays location city and country when location is set', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          selectedLocationProvider.overrideWith(MockSelectedLocation.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Should display city and country (covers L202)
      expect(find.text('Jakarta, Indonesia'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      // Cleanup
      await satisfyFirstWhere(tester);
    });

    testWidgets('shows remove location button when location is selected', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          addStoryRepositoryProvider.overrideWithValue(mockRepository),
          listRepositoryProvider.overrideWithValue(mockListRepository),
          selectedLocationProvider.overrideWith(MockSelectedLocation.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Remove location button should be visible (covers L209-219)
      expect(find.text('Remove Location'), findsOneWidget);

      // Cleanup
      await satisfyFirstWhere(tester);
    });

    testWidgets('addStory is called with lat/lon when location is set', (
      tester,
    ) async {
      when(
        () => mockRepository.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer(
        (_) async => Right(DefaultResponse(error: false, message: 'Success')),
      );

      await tester.runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            addStoryRepositoryProvider.overrideWithValue(mockRepository),
            listRepositoryProvider.overrideWithValue(mockListRepository),
            selectedLocationProvider.overrideWith(MockSelectedLocation.new),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createWidgetUnderTest(container: container));
        await tester.pumpAndSettle();

        // Add image via stream
        when(() => mockData.croppedFile).thenReturn(testFile);
        when(() => mockDetails.data).thenReturn([mockData]);
        streamController.add(mockDetails);
        await tester.pump();
      });

      await tester.pump();

      // Enter description
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test with location',
      );
      await tester.pump();

      // Tap post button
      await tester.tap(find.byKey(const Key('postButton')));
      await tester.pump();

      // Verify repository was called with lat/lon (covers L101-102)
      verify(
        () => mockRepository.addStory(
          'Test with location',
          any(),
          lat: -6.2,
          lon: 106.8,
        ),
      ).called(1);
    });
  });
}
