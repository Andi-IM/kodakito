import 'package:dicoding_story/common/globals.dart';
import 'package:dicoding_story/common/theme.dart';
import 'package:dicoding_story/data/services/local/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('AppLanguageNotifier', () {
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      // Default setup for getCurrentLanguage call in constructor
      when(
        () => mockStorageService.get(APP_LANGUAGE_STORAGE_KEY),
      ).thenAnswer((_) async => null);
    });

    test('initial state is null (system preferred)', () async {
      final notifier = AppLanguageNotifier(mockStorageService);

      // Wait for async getCurrentLanguage to complete
      await Future.delayed(Duration.zero);

      expect(notifier.state, isNull);
    });

    group('changeLanguage', () {
      test(
        'sets state to null and stores "system" when locale is null',
        () async {
          when(
            () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'system'),
          ).thenAnswer((_) async => true);

          final notifier = AppLanguageNotifier(mockStorageService);
          await Future.delayed(Duration.zero);

          notifier.changeLanguage(null);
          await Future.delayed(Duration.zero);

          expect(notifier.state, isNull);
          verify(
            () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'system'),
          ).called(1);
        },
      );

      test(
        'sets state to locale and stores language code when locale is en',
        () async {
          when(
            () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'en'),
          ).thenAnswer((_) async => true);

          final notifier = AppLanguageNotifier(mockStorageService);
          await Future.delayed(Duration.zero);

          const enLocale = Locale('en');
          notifier.changeLanguage(enLocale);
          await Future.delayed(Duration.zero);

          expect(notifier.state, equals(enLocale));
          verify(
            () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'en'),
          ).called(1);
        },
      );

      test(
        'sets state to locale and stores language code when locale is id',
        () async {
          when(
            () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'id'),
          ).thenAnswer((_) async => true);

          final notifier = AppLanguageNotifier(mockStorageService);
          await Future.delayed(Duration.zero);

          const idLocale = Locale('id');
          notifier.changeLanguage(idLocale);
          await Future.delayed(Duration.zero);

          expect(notifier.state, equals(idLocale));
          verify(
            () => mockStorageService.set(APP_LANGUAGE_STORAGE_KEY, 'id'),
          ).called(1);
        },
      );
    });

    group('getCurrentLanguage', () {
      test('sets state to null when stored value is null', () async {
        when(
          () => mockStorageService.get(APP_LANGUAGE_STORAGE_KEY),
        ).thenAnswer((_) async => null);

        final notifier = AppLanguageNotifier(mockStorageService);
        await Future.delayed(Duration.zero);

        expect(notifier.state, isNull);
      });

      test('sets state to null when stored value is "system"', () async {
        when(
          () => mockStorageService.get(APP_LANGUAGE_STORAGE_KEY),
        ).thenAnswer((_) async => 'system');

        final notifier = AppLanguageNotifier(mockStorageService);
        await Future.delayed(Duration.zero);

        expect(notifier.state, isNull);
      });

      test(
        'sets state to Locale when stored value is a language code',
        () async {
          when(
            () => mockStorageService.get(APP_LANGUAGE_STORAGE_KEY),
          ).thenAnswer((_) async => 'en');

          final notifier = AppLanguageNotifier(mockStorageService);
          await Future.delayed(Duration.zero);

          expect(notifier.state, equals(const Locale('en')));
        },
      );
    });
  });

  group('AppThemeNotifier', () {
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      // Default setup for getCurrentTheme call in constructor
      when(
        () => mockStorageService.get(APP_THEME_STORAGE_KEY),
      ).thenAnswer((_) async => null);
    });

    test('initial state is ThemeMode.light', () async {
      final notifier = AppThemeNotifier(mockStorageService);

      // Before async completes, default is light
      expect(notifier.state, equals(ThemeMode.light));
    });

    group('changeTheme', () {
      test('sets state and stores theme name for ThemeMode.dark', () async {
        when(
          () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'dark'),
        ).thenAnswer((_) async => true);

        final notifier = AppThemeNotifier(mockStorageService);
        await Future.delayed(Duration.zero);

        notifier.changeTheme(ThemeMode.dark);
        await Future.delayed(Duration.zero);

        expect(notifier.state, equals(ThemeMode.dark));
        verify(
          () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'dark'),
        ).called(1);
      });

      test('sets state and stores theme name for ThemeMode.light', () async {
        when(
          () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'light'),
        ).thenAnswer((_) async => true);

        final notifier = AppThemeNotifier(mockStorageService);
        await Future.delayed(Duration.zero);

        notifier.changeTheme(ThemeMode.light);
        await Future.delayed(Duration.zero);

        expect(notifier.state, equals(ThemeMode.light));
        verify(
          () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'light'),
        ).called(1);
      });

      test('sets state and stores theme name for ThemeMode.system', () async {
        when(
          () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'system'),
        ).thenAnswer((_) async => true);

        final notifier = AppThemeNotifier(mockStorageService);
        await Future.delayed(Duration.zero);

        notifier.changeTheme(ThemeMode.system);
        await Future.delayed(Duration.zero);

        expect(notifier.state, equals(ThemeMode.system));
        verify(
          () => mockStorageService.set(APP_THEME_STORAGE_KEY, 'system'),
        ).called(1);
      });
    });

    group('getCurrentTheme', () {
      test('sets state to ThemeMode.light when stored value is null', () async {
        when(
          () => mockStorageService.get(APP_THEME_STORAGE_KEY),
        ).thenAnswer((_) async => null);

        final notifier = AppThemeNotifier(mockStorageService);
        await Future.delayed(Duration.zero);

        expect(notifier.state, equals(ThemeMode.light));
      });

      test(
        'sets state to ThemeMode.dark when stored value is "dark"',
        () async {
          when(
            () => mockStorageService.get(APP_THEME_STORAGE_KEY),
          ).thenAnswer((_) async => 'dark');

          final notifier = AppThemeNotifier(mockStorageService);
          await Future.delayed(Duration.zero);

          expect(notifier.state, equals(ThemeMode.dark));
        },
      );

      test(
        'sets state to ThemeMode.system when stored value is "system"',
        () async {
          when(
            () => mockStorageService.get(APP_THEME_STORAGE_KEY),
          ).thenAnswer((_) async => 'system');

          final notifier = AppThemeNotifier(mockStorageService);
          await Future.delayed(Duration.zero);

          expect(notifier.state, equals(ThemeMode.system));
        },
      );
    });
  });
}
