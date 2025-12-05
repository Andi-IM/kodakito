import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/data_providers.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDetailRepository extends Mock implements DetailRepository {}

class MockNetworkImageService extends Mock implements NetworkImageService {}

void main() {
  late MockDetailRepository mockRepository;
  late ProviderContainer container;

  late MockNetworkImageService mockNetworkImageService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepository = MockDetailRepository();
    mockNetworkImageService = MockNetworkImageService();
    container = ProviderContainer(
      overrides: [
        detailRepositoryProvider.overrideWithValue(mockRepository),
        networkImageServiceProvider.overrideWith(
          (ref) => mockNetworkImageService,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tStory = Story(
    id: '1',
    name: 'Test Story',
    description: 'Description',
    photoUrl: 'url',
    createdAt: DateTime(2022, 1, 1),
    lat: 0.0,
    lon: 0.0,
  );

  test('initial state is initial', () {
    when(
      () => mockRepository.getDetailStory(any()),
    ).thenAnswer((_) async => Right(tStory));

    final sub = container.listen(detailScreenContentProvider('1'), (_, __) {});

    expect(sub.read(), const StoryState.initial());
  });

  test('fetchDetailStory success updates state to loaded', () async {
    when(
      () => mockRepository.getDetailStory('1'),
    ).thenAnswer((_) async => Right(tStory));

    final sub = container.listen(detailScreenContentProvider('1'), (_, __) {});

    // Wait for microtask to complete
    await container.pump();
    await Future.delayed(Duration.zero);

    expect(sub.read().state, StoryStateType.loaded);
    expect(sub.read().story, tStory);
    verify(() => mockRepository.getDetailStory('1')).called(1);
  });

  test('fetchDetailStory failure updates state to error', () async {
    final tError = AppException(
      message: 'Network Error',
      statusCode: 500,
      identifier: 'TEST_ERROR',
    );
    when(
      () => mockRepository.getDetailStory('1'),
    ).thenAnswer((_) async => Left(tError));

    final sub = container.listen(detailScreenContentProvider('1'), (_, __) {});

    // Wait for microtask to complete
    await container.pump();
    await Future.delayed(Duration.zero);

    expect(sub.read().state, StoryStateType.error);
    expect(sub.read().errorMessage, 'Network Error');
    verify(() => mockRepository.getDetailStory('1')).called(1);
  });

  test('resetState resets state to initial', () async {
    when(
      () => mockRepository.getDetailStory('1'),
    ).thenAnswer((_) async => Right(tStory));

    final sub = container.listen(detailScreenContentProvider('1'), (_, __) {});

    // Wait for loaded
    await container.pump();
    await Future.delayed(Duration.zero);
    expect(sub.read().state, StoryStateType.loaded);

    // Reset
    container.read(detailScreenContentProvider('1').notifier).resetState();

    expect(sub.read(), const StoryState.initial());
  });

  group('storyColorScheme', () {
    test('returns null when imageUrl is empty (get returns null)', () async {
      when(
        () => mockNetworkImageService.get(any()),
      ).thenAnswer((_) async => null);

      final result = await container.read(storyColorSchemeProvider('').future);
      expect(result, null);
    });

    test('returns ColorScheme when image loads successfully', () async {
      final file = File('d:/dicoding_story/assets/logo_dark.png');
      final bytes = await file.readAsBytes();

      when(
        () => mockNetworkImageService.get(any()),
      ).thenAnswer((_) async => bytes);

      final result = await container.read(
        storyColorSchemeProvider('test_image').future,
      );
      expect(result, isA<ColorScheme?>());
    });

    test('returns valid ColorScheme using logo_dark.png', () async {
      final file = File('d:/dicoding_story/assets/logo_dark.png');
      final bytes = await file.readAsBytes();

      when(
        () => mockNetworkImageService.get(any()),
      ).thenAnswer((_) async => bytes);

      final result = await container.read(
        storyColorSchemeProvider('test_image').future,
      );

      expect(result, isNotNull);
      expect(result, isA<ColorScheme>());
      expect(result?.primary, isNotNull);
    });
  });
}
