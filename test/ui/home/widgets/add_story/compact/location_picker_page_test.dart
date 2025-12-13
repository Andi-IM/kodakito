import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/home/view_model/location_picker_view_model.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/compact/location_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockLocationPicker extends LocationPicker with Mock {
  MockLocationPicker(this._initialState);

  final LocationPickerState _initialState;

  @override
  LocationPickerState build(PlaceInfo? initialLocation) {
    return _initialState;
  }

  @override
  Future<void> updateLocation(LatLng latLng) async {
    return super.noSuchMethod(Invocation.method(#updateLocation, [latLng]));
  }

  @override
  Future<LatLng?> moveToCurrentLocation() async {
    return super.noSuchMethod(Invocation.method(#moveToCurrentLocation, []));
  }
}

void main() {
  late MockGoRouter mockGoRouter;

  setUpAll(() {
    registerFallbackValue(
      PlaceInfo(
        formattedAddress: '',
        street: '',
        locality: '',
        city: '',
        state: '',
        country: '',
        postalCode: '',
        latitude: 0,
        longitude: 0,
      ),
    );
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  Widget buildTestWidget({
    required ProviderContainer container,
    PlaceInfo? initialLocation,
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
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: LocationPickerPage(initialLocation: initialLocation),
        ),
      ),
    );
  }

  group('LocationPickerPage', () {
    testWidgets('renders AppBar with title', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders confirm button in AppBar', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders GoogleMap widget', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('renders zoom control buttons', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('renders instruction and coordinates cards', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('displays coordinates when no placeInfo', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.textContaining('-6.208800'), findsOneWidget);
    });

    testWidgets('displays city and state when placeInfo is available', (
      tester,
    ) async {
      final placeInfo = PlaceInfo(
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

      final initialState = LocationPickerState(
        selectedLocation: LatLng(placeInfo.latitude, placeInfo.longitude),
        placeInfo: placeInfo,
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.text('Jakarta, DKI Jakarta'), findsOneWidget);
    });

    testWidgets('displays loading indicator when isLoading', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2, 106.8),
        isLoading: true,
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('confirm button pops with placeInfo', (tester) async {
      final placeInfo = PlaceInfo(
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

      final initialState = LocationPickerState(
        selectedLocation: LatLng(placeInfo.latitude, placeInfo.longitude),
        placeInfo: placeInfo,
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      when(() => mockGoRouter.pop(any())).thenReturn(null);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      verify(() => mockGoRouter.pop(placeInfo)).called(1);
    });

    testWidgets('GoogleMap onTap calls updateLocation', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );
      final mockPicker = MockLocationPicker(initialState);

      // Stub updateLocation to do nothing
      when(() => mockPicker.updateLocation(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(null).overrideWith(() => mockPicker),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      // Get the GoogleMap widget and invoke its onTap callback
      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMap.onTap!(const LatLng(1.0, 2.0));
      await tester.pump();

      verify(() => mockPicker.updateLocation(const LatLng(1.0, 2.0))).called(1);
    });

    testWidgets('Marker onDragEnd calls updateLocation', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );
      final mockPicker = MockLocationPicker(initialState);

      // Stub updateLocation
      when(() => mockPicker.updateLocation(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(null).overrideWith(() => mockPicker),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      // Get the GoogleMap widget and find the marker
      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      final marker = googleMap.markers.first;

      // Invoke onDragEnd callback
      marker.onDragEnd!(const LatLng(3.0, 4.0));
      await tester.pump();

      verify(() => mockPicker.updateLocation(const LatLng(3.0, 4.0))).called(1);
    });

    testWidgets('my location button calls moveToCurrentLocation', (
      tester,
    ) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );
      final mockPicker = MockLocationPicker(initialState);
      when(
        () => mockPicker.moveToCurrentLocation(),
      ).thenAnswer((_) async => const LatLng(5.0, 6.0));

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(null).overrideWith(() => mockPicker),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      // Tap my location button
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump();

      verify(() => mockPicker.moveToCurrentLocation()).called(1);
    });

    testWidgets('zoom in button can be tapped', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      // Tap zoom in button - should not throw
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // No exception means the callback was executed
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('zoom out button can be tapped', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      // Tap zoom out button - should not throw
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // No exception means the callback was executed
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('GoogleMap onMapCreated callback is set', (tester) async {
      final initialState = const LocationPickerState(
        selectedLocation: LatLng(-6.2088, 106.8456),
      );

      final container = ProviderContainer(
        overrides: [
          locationPickerProvider(
            null,
          ).overrideWith(() => MockLocationPicker(initialState)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pump();

      // Get the GoogleMap widget and verify onMapCreated is set
      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(googleMap.onMapCreated, isNotNull);
    });
  });
}
