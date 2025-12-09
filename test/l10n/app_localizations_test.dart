import 'package:dicoding_story/l10n/app_localizations.dart';
import 'package:dicoding_story/l10n/app_localizations_en.dart';
import 'package:dicoding_story/l10n/app_localizations_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lookupAppLocalizations', () {
    test('returns AppLocalizationsEn for English locale', () {
      const locale = Locale('en');
      final result = lookupAppLocalizations(locale);

      expect(result, isA<AppLocalizationsEn>());
      expect(result.localeName, 'en');
    });

    test('returns AppLocalizationsId for Indonesian locale', () {
      const locale = Locale('id');
      final result = lookupAppLocalizations(locale);

      expect(result, isA<AppLocalizationsId>());
      expect(result.localeName, 'id');
    });

    test('throws FlutterError for unsupported locale', () {
      const locale = Locale('fr'); // French is not supported

      expect(
        () => lookupAppLocalizations(locale),
        throwsA(isA<FlutterError>()),
      );
    });

    test(
      'FlutterError message contains locale info for unsupported locale',
      () {
        const locale = Locale('de'); // German is not supported

        try {
          lookupAppLocalizations(locale);
          fail('Expected FlutterError to be thrown');
        } on FlutterError catch (e) {
          expect(e.message, contains('de'));
          expect(e.message, contains('unsupported locale'));
        }
      },
    );
  });

  group('_AppLocalizationsDelegate', () {
    test('delegate isSupported returns true for en', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
    });

    test('delegate isSupported returns true for id', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('id')), isTrue);
    });

    test('delegate isSupported returns false for unsupported locale', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test(
      'delegate load returns AppLocalizations for supported locale',
      () async {
        const delegate = AppLocalizations.delegate;
        final result = await delegate.load(const Locale('en'));

        expect(result, isA<AppLocalizations>());
        expect(result, isA<AppLocalizationsEn>());
      },
    );

    test('delegate shouldReload returns false', () {
      const delegate = AppLocalizations.delegate;
      // shouldReload should always return false for this delegate
      expect(delegate.shouldReload(delegate), isFalse);
    });
  });

  group('AppLocalizations', () {
    test('supportedLocales contains en and id', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('id')));
      expect(AppLocalizations.supportedLocales.length, 2);
    });

    test('localizationsDelegates is not empty', () {
      expect(AppLocalizations.localizationsDelegates, isNotEmpty);
      expect(
        AppLocalizations.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
    });
  });
}
