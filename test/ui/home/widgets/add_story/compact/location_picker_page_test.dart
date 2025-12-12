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

class MockLocationPicker extends LocationPicker {
  LocationPickerState _state;

  MockLocationPicker(this._state);

  @override
  LocationPickerState build(PlaceInfo? initialLocation) => _state;

  void setState(LocationPickerState newState) {
    _state = newState;
    state = newState;
  }

  @override
  Future<void> updateLocation(LatLng latLng) async {}

  @override
  Future<LatLng?> moveToCurrentLocation() async => null;

  @override
  Future<void> fetchCurrentLocation() async {}
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
  });
}
