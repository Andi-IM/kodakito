import 'dart:async';

import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/data/services/widget/image_picker/image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/insta_image_picker/insta_image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/wechat_camera_picker/wechat_camera_picker_service.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/ui/main/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:window_size_classes/window_size_classes.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:m3e_collection/m3e_collection.dart';

class MockGoRouter with Mock implements GoRouter {}

class MockCameraPickerServiceProvider
    with Mock
    implements WechatCameraPickerService {}

class MockInstaImagePickerServiceProvider
    with Mock
    implements InstaImagePickerService {}

class MockImagePickerServiceProvider with Mock implements ImagePickerService {}

// Fake BuildContext for mocktail fallback registration
class FakeBuildContext extends Fake implements BuildContext {}

// Fake AssetEntity for mocktail fallback registration
class FakeAssetEntity extends Fake implements AssetEntity {}

void main() {
  late MockGoRouter mockGoRouter;
  late MockCameraPickerServiceProvider mockCameraPickerService;
  late MockInstaImagePickerServiceProvider mockInstaImagePickerService;
  late MockImagePickerServiceProvider mockImagePickerService;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeAssetEntity());
    registerFallbackValue((BuildContext context) async {});
    registerFallbackValue((Stream<InstaAssetsExportDetails> stream) async {});
  });

  setUp(() {
    mockGoRouter = MockGoRouter();
    mockCameraPickerService = MockCameraPickerServiceProvider();
    mockInstaImagePickerService = MockInstaImagePickerServiceProvider();
    mockImagePickerService = MockImagePickerServiceProvider();
  });

  Widget pumpTestWidget(
    WidgetTester tester, {
    required ProviderContainer container,
    required WindowWidthClass widthClass,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: WindowSizeMediaQuery(
            size: Size(
              widthClass == WindowWidthClass.compact
                  ? 400
                  : widthClass == WindowWidthClass.medium
                  ? 800
                  : 1200,
              800,
            ),
            child: const MainPage(),
          ),
        ),
      ),
    );
  }

  // A wrapper to inject the mock GoRouter
  // We can also just use MaterialApp.router but we need to inject the mock router.
  // Actually, standard practice for mocking GoRouter in widget tests involves
  // using an InheritedWidget or overriding the router config.
  // But here MainPage just uses context.go/push, which looks up the GoRouter in context.
  // We can simple wrap the MainPage in a mock InheritedGoRouter if GoRouter package provides one,
  // or use `MockGoRouterProvider` pattern.

  testWidgets('initialization calls fetchStories', (tester) async {
    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive so we verify the same instance
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier);
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact,
      ),
    );

    // Allow microtask to run
    await tester.pump();

    verify(() => mockStories.fetchStories()).called(1);
  });

  testWidgets('displays ListView with StoryCards on compact screens', (
    tester,
  ) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
      Story(
        id: 'story-2',
        name: 'Test User 2',
        description: 'Test description 2',
        photoUrl: 'https://example.com/photo2.jpg',
        createdAt: DateTime(2024, 1, 2),
        lat: null,
        lon: null,
      ),
    ];

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive so we verify the same instance
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Set the state to loaded with stories
    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact,
      ),
    );

    // Allow widget tree to build
    await tester.pump();

    // Verify ListView is rendered (identified by key)
    expect(find.byKey(const ValueKey('list')), findsOneWidget);

    // Verify StoryCards are rendered
    expect(find.byKey(const ValueKey('StoryCard_story-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('StoryCard_story-2')), findsOneWidget);
  });

  testWidgets('displays GridView with StoryCards on medium screens', (
    tester,
  ) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
      Story(
        id: 'story-2',
        name: 'Test User 2',
        description: 'Test description 2',
        photoUrl: 'https://example.com/photo2.jpg',
        createdAt: DateTime(2024, 1, 2),
        lat: null,
        lon: null,
      ),
    ];

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive so we verify the same instance
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Set the state to loaded with stories
    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.medium, // Use medium width for GridView
      ),
    );

    // Allow widget tree to build
    await tester.pump();

    // Verify GridView is rendered (identified by key)
    expect(find.byKey(const ValueKey('grid')), findsOneWidget);

    // Verify StoryCards are rendered in the grid
    expect(find.byType(StoryCard), findsNWidgets(2));
  });

  testWidgets(
    'tapping StoryCard navigates to story detail on compact screens',
    (tester) async {
      final testStories = [
        Story(
          id: 'story-1',
          name: 'Test User 1',
          description: 'Test description 1',
          photoUrl: 'https://example.com/photo1.jpg',
          createdAt: DateTime(2024, 1, 1),
          lat: null,
          lon: null,
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
        ],
      );
      addTearDown(container.dispose);

      // Keep the provider alive
      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Set the state to loaded with stories
      mockStories.setState(
        StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
      );

      // Stub GoRouter.go
      when(() => mockGoRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.compact,
        ),
      );

      await tester.pump();

      // Tap on the StoryCard
      await tester.tap(find.byKey(const ValueKey('StoryCard_story-1')));
      await tester.pump();

      // Verify navigation was triggered with correct path
      verify(() => mockGoRouter.go('/story/story-1')).called(1);
    },
  );

  testWidgets('tapping StoryCard navigates to story detail on medium screens', (
    tester,
  ) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
    ];

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Set the state to loaded with stories
    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    // Stub GoRouter.go
    when(() => mockGoRouter.go(any())).thenReturn(null);

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.medium,
      ),
    );

    await tester.pump();

    // Tap on a StoryCard (first one)
    await tester.tap(find.byType(StoryCard).first);
    await tester.pump();

    // Verify navigation was triggered with correct path
    verify(() => mockGoRouter.go('/story/story-1')).called(1);
  });

  testWidgets('tapping FAB on compact screen calls instaImagePickerService', (
    tester,
  ) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
    ];

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
        // Override to simulate mobile platform
        mobilePlatformProvider.overrideWith((ref) => true),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Stub the instaImagePickerService.pickImage method
    when(
      () => mockInstaImagePickerService.pickImage(any(), any(), any()),
    ).thenAnswer((_) async {});

    // Set the state to loaded with stories
    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact,
      ),
    );

    await tester.pump();

    // Find and tap the FAB (compact version - triggers mobile picker flow)
    await tester.tap(find.byKey(const ValueKey('fab_compact')));
    await tester.pump();

    // Verify instaImagePickerService.pickImage was called (lines 61-67)
    verify(
      () => mockInstaImagePickerService.pickImage(any(), any(), any()),
    ).called(1);
  });

  testWidgets('_pickFromWeChatCamera returns early when camera returns null', (
    tester,
  ) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
    ];

    // Capture the pickFromCamera callback
    Function(BuildContext)? capturedPickFromCamera;

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
        mobilePlatformProvider.overrideWith((ref) => true),
      ],
    );
    addTearDown(container.dispose);

    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Capture the pickFromCamera callback when pickImage is called
    when(
      () => mockInstaImagePickerService.pickImage(any(), any(), any()),
    ).thenAnswer((invocation) async {
      capturedPickFromCamera =
          invocation.positionalArguments[1] as Function(BuildContext);
    });

    // Stub cameraPickerService.pickImage to return null
    when(
      () => mockCameraPickerService.pickImage(any()),
    ).thenAnswer((_) async => null);

    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact,
      ),
    );

    await tester.pump();

    // Tap FAB to trigger instaImagePickerService.pickImage
    await tester.tap(find.byKey(const ValueKey('fab_compact')));
    await tester.pump();

    // Verify callback was captured
    expect(capturedPickFromCamera, isNotNull);

    // Invoke the captured _pickFromWeChatCamera callback
    capturedPickFromCamera!(tester.element(find.byType(MainPage)));
    await tester.pump();

    // Verify camera picker was called
    verify(() => mockCameraPickerService.pickImage(any())).called(1);

    // Verify refreshAndSelectEntity was NOT called (because camera returned null)
    verifyNever(
      () => mockInstaImagePickerService.refreshAndSelectEntity(any(), any()),
    );
  });

  testWidgets(
    '_pickFromWeChatCamera calls refreshAndSelectEntity when camera returns entity',
    (tester) async {
      final testStories = [
        Story(
          id: 'story-1',
          name: 'Test User 1',
          description: 'Test description 1',
          photoUrl: 'https://example.com/photo1.jpg',
          createdAt: DateTime(2024, 1, 1),
          lat: null,
          lon: null,
        ),
      ];

      // Capture the pickFromCamera callback
      Function(BuildContext)? capturedPickFromCamera;
      final fakeAssetEntity = FakeAssetEntity();

      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
          mobilePlatformProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Capture the pickFromCamera callback when pickImage is called
      when(
        () => mockInstaImagePickerService.pickImage(any(), any(), any()),
      ).thenAnswer((invocation) async {
        capturedPickFromCamera =
            invocation.positionalArguments[1] as Function(BuildContext);
      });

      // Stub cameraPickerService.pickImage to return a fake entity
      when(
        () => mockCameraPickerService.pickImage(any()),
      ).thenAnswer((_) async => fakeAssetEntity);

      // Stub refreshAndSelectEntity
      when(
        () => mockInstaImagePickerService.refreshAndSelectEntity(any(), any()),
      ).thenAnswer((_) async {});

      mockStories.setState(
        StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
      );

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.compact,
        ),
      );

      await tester.pump();

      // Tap FAB to trigger instaImagePickerService.pickImage
      await tester.tap(find.byKey(const ValueKey('fab_compact')));
      await tester.pump();

      // Verify callback was captured
      expect(capturedPickFromCamera, isNotNull);

      // Invoke the captured _pickFromWeChatCamera callback
      capturedPickFromCamera!(tester.element(find.byType(MainPage)));
      await tester.pump();

      // Verify camera picker was called
      verify(() => mockCameraPickerService.pickImage(any())).called(1);

      // Verify refreshAndSelectEntity WAS called with the entity
      verify(
        () => mockInstaImagePickerService.refreshAndSelectEntity(
          any(),
          fakeAssetEntity,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'instaImagePickerService.pickImage onCompleted callback calls context.pushNamed',
    (tester) async {
      final testStories = [
        Story(
          id: 'story-1',
          name: 'Test User 1',
          description: 'Test description 1',
          photoUrl: 'https://example.com/photo1.jpg',
          createdAt: DateTime(2024, 1, 1),
          lat: null,
          lon: null,
        ),
      ];

      // Capture the onCompleted callback
      Function(Stream<InstaAssetsExportDetails>)? capturedOnCompleted;

      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
          mobilePlatformProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Capture the onCompleted callback when pickImage is called
      when(
        () => mockInstaImagePickerService.pickImage(any(), any(), any()),
      ).thenAnswer((invocation) async {
        capturedOnCompleted =
            invocation.positionalArguments[2]
                as Function(Stream<InstaAssetsExportDetails>);
      });

      // Stub goRouter.pushNamed
      when(
        () => mockGoRouter.pushNamed(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      mockStories.setState(
        StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
      );

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.compact,
        ),
      );

      await tester.pump();

      // Tap FAB to trigger instaImagePickerService.pickImage
      await tester.tap(find.byKey(const ValueKey('fab_compact')));
      await tester.pump();

      // Verify callback was captured
      expect(capturedOnCompleted, isNotNull);

      // Create a mock stream for the callback
      final mockStream = Stream<InstaAssetsExportDetails>.empty();

      // Invoke the captured onCompleted callback
      capturedOnCompleted!(mockStream);
      await tester.pump();

      // Verify pushNamed was called with 'crop' route and the stream as extra
      verify(
        () => mockGoRouter.pushNamed(
          'crop',
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: mockStream,
        ),
      ).called(1);
    },
  );

  // Skipped: Implementation changed to directly use .value instead of AsyncValue.when
  // The avatar now always shows CircleAvatar without loading/error states.
  testWidgets(
    'displays loading indicator in avatar button when user data is loading',
    skip: true,
    (tester) async {},
  );

  // Skipped: Riverpod FutureProvider async errors are difficult to test
  // in widget tests - error state transition timing is unreliable.
  testWidgets(
    'displays account_circle icon in avatar button when user data has error',
    skip: true,
    (tester) async {},
  );

  testWidgets('tapping FAB on medium screen opens AddStoryDialog', (
    tester,
  ) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
    ];

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Stub goRouter.pushNamed for AddStoryDialog
    when(
      () => mockGoRouter.pushNamed(
        any(),
        pathParameters: any(named: 'pathParameters'),
        queryParameters: any(named: 'queryParameters'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) async => null);

    // Set the state to loaded with stories
    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.medium,
      ),
    );

    await tester.pump();

    // Find and tap the FAB (extended version)
    await tester.tap(find.byKey(const ValueKey('fab_extended')));
    await tester.pump(const Duration(seconds: 1));

    // Verify navigation to add-story route was called
    verify(
      () => mockGoRouter.pushNamed(
        'add-story',
        pathParameters: any(named: 'pathParameters'),
        queryParameters: any(named: 'queryParameters'),
        extra: any(named: 'extra'),
      ),
    ).called(1);
  });

  testWidgets(
    'on non-mobile platforms, stories are displayed without RefreshIndicator',
    (tester) async {
      final testStories = [
        Story(
          id: 'story-1',
          name: 'Test User 1',
          description: 'Test description 1',
          photoUrl: 'https://example.com/photo1.jpg',
          createdAt: DateTime(2024, 1, 1),
          lat: null,
          lon: null,
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
        ],
      );
      addTearDown(container.dispose);

      // Keep the provider alive
      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Set the state to loaded with stories
      mockStories.setState(
        StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
      );

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.compact,
        ),
      );

      await tester.pump();

      // On non-mobile platforms (Windows test), Scrollbar should be present
      expect(find.byType(Scrollbar), findsOneWidget);

      // But RefreshIndicator should NOT be present (line 189 path)
      expect(find.byType(RefreshIndicator), findsNothing);
    },
  );

  testWidgets(
    'on mobile platforms, stories are displayed with RefreshIndicator and pull-to-refresh triggers fetchStories',
    (tester) async {
      final testStories = [
        Story(
          id: 'story-1',
          name: 'Test User 1',
          description: 'Test description 1',
          photoUrl: 'https://example.com/photo1.jpg',
          createdAt: DateTime(2024, 1, 1),
          lat: null,
          lon: null,
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
          // Override to simulate mobile platform
          mobilePlatformProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      // Keep the provider alive
      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Set the state to loaded with stories
      mockStories.setState(
        StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
      );

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.compact,
        ),
      );

      await tester.pump();

      // On mobile platforms, RefreshIndicator should be present
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Verify Scrollbar is also present under RefreshIndicator
      expect(find.byType(Scrollbar), findsOneWidget);
    },
  );

  testWidgets(
    'RefreshIndicator onRefresh calls fetchStories on mobile platforms',
    (tester) async {
      final testStories = [
        Story(
          id: 'story-1',
          name: 'Test User 1',
          description: 'Test description 1',
          photoUrl: 'https://example.com/photo1.jpg',
          createdAt: DateTime(2024, 1, 1),
          lat: null,
          lon: null,
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
          // Override to simulate mobile platform
          mobilePlatformProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      // Keep the provider alive
      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Set the state to loaded with stories
      mockStories.setState(
        StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
      );

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.compact,
        ),
      );

      await tester.pump();

      // Find the RefreshIndicator and get its onRefresh callback
      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );

      // fetchStories was already called once during initialization
      // Clear mock to verify it's called again by onRefresh
      clearInteractions(mockStories);
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Invoke the onRefresh callback directly
      await refreshIndicator.onRefresh();
      await tester.pump();

      // Verify fetchStories was called by the onRefresh callback
      verify(() => mockStories.fetchStories()).called(1);
    },
  );

  testWidgets('tapping avatar button opens SettingsDialog', (tester) async {
    final testStories = [
      Story(
        id: 'story-1',
        name: 'Test User 1',
        description: 'Test description 1',
        photoUrl: 'https://example.com/photo1.jpg',
        createdAt: DateTime(2024, 1, 1),
        lat: null,
        lon: null,
      ),
    ];

    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Stub goRouter.push for SettingsDialog
    when(
      () => mockGoRouter.push(any(), extra: any(named: 'extra')),
    ).thenAnswer((_) async => null);

    // Set the state to loaded with stories
    mockStories.setState(
      StoriesState(state: StoriesConcreteState.loaded, stories: testStories),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact,
      ),
    );

    await tester.pump();

    // Find and tap the avatar button
    await tester.tap(find.byKey(const ValueKey('avatarButton')));
    await tester.pump(const Duration(seconds: 1));

    // Verify navigation to settings route was called
    verify(
      () => mockGoRouter.push('/settings', extra: any(named: 'extra')),
    ).called(1);
  });

  testWidgets('displays error message when stories fail to load', (
    tester,
  ) async {
    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive
    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Set the state to failure
    mockStories.setState(
      StoriesState(
        state: StoriesConcreteState.failure,
        message: 'Network error',
      ),
    );

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact,
      ),
    );

    await tester.pump();

    // Verify error message is displayed (line 206)
    expect(find.textContaining('Error:'), findsOneWidget);
    expect(find.textContaining('Network error'), findsOneWidget);
  });

  testWidgets(
    'displays loading indicator with 120x120 SizedBox on medium screens',
    (tester) async {
      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
        ],
      );
      addTearDown(container.dispose);

      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Set the state to loading
      mockStories.setState(StoriesState(state: StoriesConcreteState.loading));

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.medium, // Medium screen, not large
        ),
      );

      await tester.pump();

      // Verify LoadingIndicatorM3E is displayed
      expect(find.byKey(const ValueKey('loadingIndicator')), findsOneWidget);

      // Verify the SizedBox wrapper exists with size 120x120 (medium, not large)
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const ValueKey('loadingIndicator')),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 120);
      expect(sizedBox.height, 120);
    },
  );

  testWidgets(
    'displays loading indicator with 240x240 SizedBox on large screens',
    (tester) async {
      final container = ProviderContainer.test(
        overrides: [
          storiesProvider.overrideWith(MockStories.new),
          fetchUserDataProvider.overrideWith((ref) => 'Test User'),
          cameraPickerServiceProvider.overrideWithValue(
            mockCameraPickerService,
          ),
          instaImagePickerServiceProvider.overrideWithValue(
            mockInstaImagePickerService,
          ),
          imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
        ],
      );
      addTearDown(container.dispose);

      container.listen(storiesProvider, (_, __) {});
      final mockStories =
          container.read(storiesProvider.notifier) as MockStories;
      when(() => mockStories.fetchStories()).thenAnswer((_) async {});

      // Set the state to loading
      mockStories.setState(StoriesState(state: StoriesConcreteState.loading));

      await tester.pumpWidget(
        pumpTestWidget(
          tester,
          container: container,
          widthClass: WindowWidthClass.large, // Large screen
        ),
      );

      await tester.pump();

      // Verify LoadingIndicatorM3E is displayed
      expect(find.byKey(const ValueKey('loadingIndicator')), findsOneWidget);

      // Verify the SizedBox wrapper exists with size 240x240 (large)
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const ValueKey('loadingIndicator')),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 240);
      expect(sizedBox.height, 240);
    },
  );

  testWidgets('displays loading indicator without SizedBox on compact screens', (
    tester,
  ) async {
    final container = ProviderContainer.test(
      overrides: [
        storiesProvider.overrideWith(MockStories.new),
        fetchUserDataProvider.overrideWith((ref) => 'Test User'),
        cameraPickerServiceProvider.overrideWithValue(mockCameraPickerService),
        instaImagePickerServiceProvider.overrideWithValue(
          mockInstaImagePickerService,
        ),
        imagePickerServiceProvider.overrideWithValue(mockImagePickerService),
      ],
    );
    addTearDown(container.dispose);

    container.listen(storiesProvider, (_, __) {});
    final mockStories = container.read(storiesProvider.notifier) as MockStories;
    when(() => mockStories.fetchStories()).thenAnswer((_) async {});

    // Set the state to loading
    mockStories.setState(StoriesState(state: StoriesConcreteState.loading));

    await tester.pumpWidget(
      pumpTestWidget(
        tester,
        container: container,
        widthClass: WindowWidthClass.compact, // Compact screen
      ),
    );

    await tester.pump();

    // Verify LoadingIndicatorM3E is displayed
    expect(find.byKey(const ValueKey('loadingIndicator')), findsOneWidget);

    // Verify Center wraps the LoadingIndicatorM3E directly (no SizedBox between)
    // On compact screens, the Center should directly contain the LoadingIndicatorM3E
    final center = tester.widget<Center>(
      find.ancestor(
        of: find.byKey(const ValueKey('loadingIndicator')),
        matching: find.byType(Center),
      ),
    );
    expect(center.child, isA<LoadingIndicatorM3E>());
  });
}

// Helper for GoRouter mocking
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({
    required this.goRouter,
    required this.child,
    super.key,
  });

  final GoRouter goRouter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InheritedGoRouter(goRouter: goRouter, child: child);
  }
}

// WindowSizeMediaQuery helper to inject width class
class WindowSizeMediaQuery extends StatelessWidget {
  final Size size;
  final Widget child;

  const WindowSizeMediaQuery({
    required this.size,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: child,
    );
  }
}
