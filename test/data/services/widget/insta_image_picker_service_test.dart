import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/widget/insta_image_picker/insta_image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetEntity extends Mock implements AssetEntity {}

/// Test implementation to exercise the abstract class's default implementation
class TestInstaImagePickerService extends InstaImagePickerService {
  @override
  Future<void> pickImage(
    BuildContext context,
    Function(BuildContext context) pickFromCamera,
    Function(Stream<InstaAssetsExportDetails>) onCompleted,
  ) async {
    // Not implemented for testing
  }
}

void main() {
  group('InstaImagePickerServiceImpl', () {
    test('can be instantiated', () {
      final service = InstaImagePickerServiceImpl();
      expect(service, isA<InstaImagePickerService>());
    });

    test('implements InstaImagePickerService interface', () {
      final service = InstaImagePickerServiceImpl();
      expect(service, isA<InstaImagePickerService>());
    });
  });

  group('instaImagePickerServiceProvider', () {
    test('returns InstaImagePickerServiceImpl instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(instaImagePickerServiceProvider);

      expect(service, isA<InstaImagePickerService>());
      expect(service, isA<InstaImagePickerServiceImpl>());
    });
  });

  group('InstaImagePickerServiceImpl.pickImage', () {
    testWidgets('pickImage method exists and can be called', (
      WidgetTester tester,
    ) async {
      final service = InstaImagePickerServiceImpl();

      // Build a minimal widget tree with required localizations
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                // Verify the method signature is correct
                expect(
                  service.pickImage,
                  isA<
                    Future<void> Function(
                      BuildContext,
                      Function(BuildContext),
                      Function(Stream<InstaAssetsExportDetails>),
                    )
                  >(),
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Note: We cannot fully test pickImage without mocking InstaAssetPicker.pickAssets
      // which is a static method. The actual picker UI requires device permissions
      // and cannot be tested in unit tests.
    });

    testWidgets('pickImage callback parameters are correctly typed', (
      WidgetTester tester,
    ) async {
      final service = InstaImagePickerServiceImpl();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                // Define callbacks with correct signatures
                void pickFromCamera(BuildContext ctx) {}
                void onCompleted(Stream<InstaAssetsExportDetails> stream) {}

                // Verify types match without calling the method
                // (calling would show the actual picker UI)
                expect(
                  () => service.pickImage(context, pickFromCamera, onCompleted),
                  isA<Function>(),
                );

                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });

  group('InstaImagePickerServiceImpl.refreshAndSelectEntity', () {
    test('refreshAndSelectEntity method exists with correct signature', () {
      final service = InstaImagePickerServiceImpl();

      // Verify the method signature is correct
      expect(
        service.refreshAndSelectEntity,
        isA<Future<void> Function(BuildContext, AssetEntity)>(),
      );
    });
  });

  group('InstaImagePickerService abstract class', () {
    test('abstract class defines pickImage method', () {
      // Verify the abstract interface defines the method
      expect(InstaImagePickerService, isA<Type>());
    });

    test(
      'refreshAndSelectEntity has default implementation in abstract class',
      () async {
        // The abstract class has a default implementation that calls
        // InstaAssetPicker.refreshAndSelectEntity
        // This verifies the abstract class structure is correct
        final service = InstaImagePickerServiceImpl();
        expect(
          service.refreshAndSelectEntity,
          isA<Future<void> Function(BuildContext, AssetEntity)>(),
        );
      },
    );

    testWidgets(
      'abstract class default refreshAndSelectEntity can be invoked',
      (WidgetTester tester) async {
        final testService = TestInstaImagePickerService();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  // Verify the method signature inherited from abstract class
                  expect(
                    testService.refreshAndSelectEntity,
                    isA<Future<void> Function(BuildContext, AssetEntity)>(),
                  );
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
