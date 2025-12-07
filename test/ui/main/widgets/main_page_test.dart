import 'package:dicoding_story/data/services/widget/image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/insta_image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/wechat_camera_picker_service.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:window_size_classes/window_size_classes.dart';
import 'package:dicoding_story/common/localizations.dart';

class MockGoRouter with Mock implements GoRouter {}

class MockCameraPickerServiceProvider
    with Mock
    implements WechatCameraPickerService {}

class MockInstaImagePickerServiceProvider
    with Mock
    implements InstaImagePickerService {}

class MockImagePickerServiceProvider with Mock implements ImagePickerService {}

void main() {
  late MockGoRouter mockGoRouter;
  late MockCameraPickerServiceProvider mockCameraPickerService;
  late MockInstaImagePickerServiceProvider mockInstaImagePickerService;
  late MockImagePickerServiceProvider mockImagePickerService;

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
