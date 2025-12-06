import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story.dart';
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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        addStoryRepositoryProvider.overrideWithValue(mockRepository),
        getCroppedImageFromPickerProvider(streamController.stream).overrideWith(
          (ref) async {
            // Emulate the logic: wait for stream and return file
            // Or simply return the mock file if we want to force state
            // adhering to testFile
            await for (final event in streamController.stream) {
              if (event.data.isNotEmpty) {
                return event.data.first.croppedFile;
              }
            }
            return null;
          },
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddStoryPage(cropStream: streamController.stream),
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

  testWidgets('calls addStory when Post button is clicked', (tester) async {
    // Stub repository
    when(
      () => mockRepository.addStory(
        any(),
        any(),
        lat: any(named: 'lat'),
        lon: any(named: 'lon'),
      ),
    ).thenAnswer(
      (_) async => Right(
        DefaultResponse(error: false, message: 'Story posted successfully'),
      ),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      when(() => mockData.croppedFile).thenReturn(testFile);
      when(() => mockDetails.data).thenReturn([mockData]);

      // Emit data to enable the file state in the widget
      streamController.add(mockDetails);
      await tester.pump(const Duration(milliseconds: 100));
    });

    await tester.pumpAndSettle();

    // Fill description
    await tester.enterText(find.byType(TextField), 'New story description');

    // Tap Post
    await tester.tap(find.text('Post'));
    await tester.pump();

    // Verify
    verify(
      () => mockRepository.addStory(
        'New story description',
        any(that: isA<File>()),
        lat: any(named: 'lat'),
        lon: any(named: 'lon'),
      ),
    ).called(1);
  });
}
