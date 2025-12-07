import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/ui/main/widgets/add_story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockInstaAssetsExportDetails extends Mock
    implements InstaAssetsExportDetails {}

class MockInstaAssetsExportData extends Mock implements InstaAssetsExportData {}

class MockAddStoryRepository extends Mock implements AddStoryRepository {}

void main() {
  late StreamController<InstaAssetsExportDetails> streamController;
  late MockInstaAssetsExportDetails mockDetails;
  late MockInstaAssetsExportData mockData;
  late MockAddStoryRepository mockRepository;
  late File testFile;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    testFile = File('${tempDir.path}/test_image.png');
    await testFile.create();
    registerFallbackValue(File('dummy')); // For repository calls
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    streamController = StreamController<InstaAssetsExportDetails>.broadcast();
    mockDetails = MockInstaAssetsExportDetails();
    mockData = MockInstaAssetsExportData();
    mockRepository = MockAddStoryRepository();
  });

  tearDown(() {
    streamController.close();
  });

  Widget createWidgetUnderTest({Function()? onSuccess}) {
    return ProviderScope(
      // ignore: scoped_providers_should_specify_dependencies
      overrides: [addStoryRepositoryProvider.overrideWithValue(mockRepository)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddStoryPage(
          cropStream: streamController.stream,
          onAddStorySuccess: onSuccess ?? () {},
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
      await tester.pumpWidget(createWidgetUnderTest());
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
      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
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
      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
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
      await tester.pumpWidget(createWidgetUnderTest());
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
      await tester.pumpWidget(createWidgetUnderTest());
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

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
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

      // Verify repository was called
      verify(
        () => mockRepository.addStory('Test description', testFile),
      ).called(1);
    });

    testWidgets('shows loading state while posting', (tester) async {
      final completer = Completer<Either<AppException, DefaultResponse>>();
      when(
        () => mockRepository.addStory(any(), any()),
      ).thenAnswer((_) => completer.future);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
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

      await tester.runAsync(() async {
        await tester.pumpWidget(
          createWidgetUnderTest(
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

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
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

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
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

      // Complete the request
      completer.complete(
        Right(DefaultResponse(error: false, message: 'Success')),
      );
      await tester.pumpAndSettle();

      // Verify button and text field are enabled again
      final postButtonAfter = tester.widget<TextButton>(
        find.byKey(const Key('postButton')),
      );
      expect(postButtonAfter.onPressed, isNotNull);

      final textFieldAfter = tester.widget<TextField>(
        find.byKey(const Key('descriptionField')),
      );
      expect(textFieldAfter.enabled, isTrue);
    });
  });
}
