import 'dart:typed_data';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/map/map_controller_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_detail_pro_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/ui/detail/widgets/pro/story_detail_with_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'image_sample.dart';

class FakeDetailScreenContent extends DetailScreenContent {
  final StoryState initialState;
  FakeDetailScreenContent(this.initialState);

  @override
  StoryState build(String id) => initialState;

  @override
  Future<void> fetchDetailStory(String id) async {}
}

/// Mock implementation of MapControllerService for testing.
class MockMapControllerService extends Mock implements MapControllerService {}

/// Fake GoogleMapController for mocktail fallback.
class FakeGoogleMapController extends Fake implements GoogleMapController {}

void main() {
  late MockMapControllerService mockMapService;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(CameraUpdate.zoomIn());
    registerFallbackValue(const LatLng(0, 0));
    registerFallbackValue(FakeGoogleMapController());
  });

  setUp(() {
    mockMapService = MockMapControllerService();
    when(() => mockMapService.isReady).thenReturn(true);
    when(() => mockMapService.zoomIn()).thenAnswer((_) async {});
    when(() => mockMapService.zoomOut()).thenAnswer((_) async {});
    when(() => mockMapService.animateCamera(any())).thenAnswer((_) async {});
    when(
      () => mockMapService.animateToPosition(any(), zoom: any(named: 'zoom')),
    ).thenAnswer((_) async {});
    when(() => mockMapService.setController(any())).thenReturn(null);
    when(() => mockMapService.dispose()).thenReturn(null);
  });

  final mockStoryWithLocation = Story(
    id: 'story-1',
    name: 'Test User',
    description: 'This is a test description for the story.',
    photoUrl: 'https://example.com/photo.jpg',
    createdAt: DateTime(2024, 1, 15),
    lat: -6.2088,
    lon: 106.8456,
  );

  final mockStoryWithoutLocation = Story(
    id: 'story-2',
    name: 'Test User',
    description: 'This is a test description.',
    photoUrl: 'https://example.com/photo.jpg',
    createdAt: DateTime(2024, 1, 15),
    lat: null,
    lon: null,
  );

  final mockPlaceInfo = PlaceInfo(
    formattedAddress: 'Test Address',
    street: 'Test Street',
    locality: 'Test Locality',
    city: 'Jakarta',
    state: 'DKI Jakarta',
    country: 'Indonesia',
    postalCode: '12345',
    latitude: -6.2088,
    longitude: 106.8456,
  );

  /// Fake map widget to replace GoogleMap in tests.
  Widget fakeMapWidget = Container(
    key: const Key('fake_map'),
    color: Colors.grey,
    child: const Center(child: Text('Fake Map')),
  );

  Widget buildTestWidget({
    required ProviderContainer container,
    required String storyId,
    required VoidCallback onBack,
    Widget? mapOverride,
    MapControllerService? mapControllerService,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StoryDetailWithMapScreen(
          id: storyId,
          onBack: onBack,
          mapOverride: mapOverride,
          mapControllerService: mapControllerService,
        ),
      ),
    );
  }

  group('StoryDetailScreenPro', () {
    testWidgets('displays loading indicator when state is Loading', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider(
            'story-1',
          ).overrideWith(() => FakeDetailScreenContent(const Loading())),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
          ),
        );
        await tester.pump();
      });

      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
    });

    testWidgets('displays error message when state is Error', (tester) async {
      const errorMessage = 'Failed to load story';
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              const Error(errorMessage: errorMessage),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
          ),
        );
        await tester.pump();
      });

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider(
            'story-1',
          ).overrideWith(() => FakeDetailScreenContent(const Loading())),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
          ),
        );
        await tester.pump();
      });

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button is disabled during loading', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider(
            'story-1',
          ).overrideWith(() => FakeDetailScreenContent(const Loading())),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
          ),
        );
        await tester.pump();
      });

      final backButton = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton).first,
      );
      expect(backButton.onPressed, isNull);
    });

    testWidgets('back button calls onBack when loaded', (tester) async {
      var backCalled = false;
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () => backCalled = true,
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('uses mapOverride instead of GoogleMap when provided', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(
                story: mockStoryWithLocation,
                imageBytes: null,
                location: mockPlaceInfo,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      // Fake map should be displayed instead of GoogleMap
      expect(find.byKey(const Key('fake_map')), findsOneWidget);
      expect(find.text('Fake Map'), findsOneWidget);
      expect(find.byType(GoogleMap), findsNothing);
    });

    testWidgets('displays no location message when story has no coordinates', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-2').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithoutLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-2',
            onBack: () {},
          ),
        );
        await tester.pump();
      });

      expect(find.byIcon(Icons.location_off), findsOneWidget);
      expect(find.text('No location data'), findsOneWidget);
    });

    testWidgets('displays zoom controls when loaded', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('zoom in button calls mapService.zoomIn', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      verify(() => mockMapService.zoomIn()).called(1);
    });

    testWidgets('zoom out button calls mapService.zoomOut', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      verify(() => mockMapService.zoomOut()).called(1);
    });

    testWidgets('displays DraggableScrollableSheet when loaded', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('displays story user name in bottom sheet', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('displays story description in bottom sheet', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      expect(
        find.text('This is a test description for the story.'),
        findsOneWidget,
      );
    });

    testWidgets('displays image from imageBytes when available', (
      tester,
    ) async {
      // Create a simple 1x1 red PNG
      final imageBytes = Uint8List.fromList(imageSample);

      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: imageBytes),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is MemoryImage,
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays user avatar with first letter', (tester) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('Retry button calls fetchDetailStory (covers L242-249)', (
      tester,
    ) async {
      var fetchCalled = false;

      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(() {
            return _MockableDetailScreenContent(
              const Error(errorMessage: 'Test error'),
              onFetch: () => fetchCalled = true,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
          ),
        );
        await tester.pump();
      });

      // Tap the Retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(fetchCalled, isTrue);
    });

    testWidgets(
      'Image.network has errorBuilder that shows error icon (covers L428-437)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                Loaded(story: mockStoryWithLocation, imageBytes: null),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await mockNetworkImages(() async {
          await tester.pumpWidget(
            buildTestWidget(
              container: container,
              storyId: 'story-1',
              onBack: () {},
              mapOverride: fakeMapWidget,
              mapControllerService: mockMapService,
            ),
          );
          await tester.pump();
        });

        // Find the Image widget
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final image = tester.widget<Image>(imageFinder);

        // Verify it has an errorBuilder
        expect(image.errorBuilder, isNotNull);

        // Manually invoke the errorBuilder to verify its output
        final errorWidget = image.errorBuilder!(
          tester.element(find.byType(StoryDetailWithMapScreen)),
          Exception('Test Error'),
          StackTrace.empty,
        );

        // Pump the error widget to verify it displays correctly
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorWidget)));

        expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      },
    );

    testWidgets(
      'GoogleMap is created with correct configuration (covers L108-117)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                Loaded(story: mockStoryWithLocation, imageBytes: null),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await mockNetworkImages(() async {
          await tester.pumpWidget(
            buildTestWidget(
              container: container,
              storyId: 'story-1',
              onBack: () {},
              // Don't provide mapOverride to test real GoogleMap creation
              mapControllerService: mockMapService,
            ),
          );
          await tester.pump();
        });

        // GoogleMap should be present
        expect(find.byType(GoogleMap), findsOneWidget);

        // Verify GoogleMap configuration
        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
        expect(googleMap.myLocationButtonEnabled, isFalse);
        expect(googleMap.zoomControlsEnabled, isFalse);
        expect(googleMap.mapToolbarEnabled, isFalse);
        expect(googleMap.markers.isNotEmpty, isTrue);
        expect(googleMap.initialCameraPosition.target.latitude, -6.2088);
        expect(googleMap.initialCameraPosition.target.longitude, 106.8456);
        expect(googleMap.initialCameraPosition.zoom, 15);
      },
    );

    testWidgets(
      'GoogleMap onMapCreated calls mapService.setController (covers L115-117)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                Loaded(story: mockStoryWithLocation, imageBytes: null),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await mockNetworkImages(() async {
          await tester.pumpWidget(
            buildTestWidget(
              container: container,
              storyId: 'story-1',
              onBack: () {},
              mapControllerService: mockMapService,
            ),
          );
          await tester.pump();
        });

        // Get the GoogleMap and invoke its onMapCreated callback
        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
        googleMap.onMapCreated!(FakeGoogleMapController());

        verify(() => mockMapService.setController(any())).called(1);
      },
    );

    testWidgets(
      'Marker onTap calls mapService.animateToPosition (covers L90-93)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                Loaded(story: mockStoryWithLocation, imageBytes: null),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await mockNetworkImages(() async {
          await tester.pumpWidget(
            buildTestWidget(
              container: container,
              storyId: 'story-1',
              onBack: () {},
              mapControllerService: mockMapService,
            ),
          );
          await tester.pump();
        });

        // Get the GoogleMap and its markers
        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
        expect(googleMap.markers.isNotEmpty, isTrue);

        // Get the marker and invoke its onTap callback
        final marker = googleMap.markers.first;
        marker.onTap!();

        verify(
          () =>
              mockMapService.animateToPosition(any(), zoom: any(named: 'zoom')),
        ).called(1);
      },
    );

    testWidgets('Sheet drag updates sheetExtentProvider (covers L72-77)', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          detailScreenContentProvider('story-1').overrideWith(
            () => FakeDetailScreenContent(
              Loaded(story: mockStoryWithLocation, imageBytes: null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          buildTestWidget(
            container: container,
            storyId: 'story-1',
            onBack: () {},
            mapOverride: fakeMapWidget,
            mapControllerService: mockMapService,
          ),
        );
        await tester.pump();
      });

      // Initial extent should be 0.25 (as verified in view model test)
      // Get initial extent from provider
      expect(container.read(sheetExtentProvider), 0.25);

      // Find the SingleChildScrollView inside the sheet to drag
      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);

      // Drag the sheet upwards
      await tester.drag(
        scrollableFinder,
        const Offset(0, -300), // Drag up significantly
      );
      await tester.pumpAndSettle();

      // Check if provider value has increased
      final newExtent = container.read(sheetExtentProvider);
      expect(newExtent, greaterThan(0.25));
    });
  });
}

/// A mockable version of DetailScreenContent that tracks fetchDetailStory calls.
class _MockableDetailScreenContent extends DetailScreenContent {
  final StoryState initialState;
  final VoidCallback? onFetch;

  _MockableDetailScreenContent(this.initialState, {this.onFetch});

  @override
  StoryState build(String id) => initialState;

  @override
  Future<void> fetchDetailStory(String id) async {
    onFetch?.call();
  }
}
