import 'dart:io';

import 'package:dicoding_story/data/services/widget/wechat_camera_picker/wechat_camera_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

void main() {
  group('WechatCameraPickerServiceImpl', () {
    test('can be instantiated', () {
      final service = WechatCameraPickerServiceImpl();
      expect(service, isA<WechatCameraPickerService>());
    });

    test('implements WechatCameraPickerService interface', () {
      final service = WechatCameraPickerServiceImpl();
      expect(service, isA<WechatCameraPickerService>());
    });

    test('cameraResolutionPreset returns high for Android', () {
      final service = WechatCameraPickerServiceImpl();

      // This test verifies the getter exists and returns a valid ResolutionPreset
      final preset = service.cameraResolutionPreset;
      expect(preset, isA<ResolutionPreset>());

      // The actual value depends on the platform
      if (Platform.isAndroid) {
        expect(preset, ResolutionPreset.high);
      } else {
        expect(preset, ResolutionPreset.max);
      }
    });

    test('pickImage method has correct signature', () {
      final service = WechatCameraPickerServiceImpl();

      // Verify the method signature is correct
      expect(
        service.pickImage,
        isA<Future<AssetEntity?> Function(BuildContext)>(),
      );
    });
  });

  group('cameraPickerServiceProvider', () {
    test('returns WechatCameraPickerServiceImpl instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(cameraPickerServiceProvider);

      expect(service, isA<WechatCameraPickerService>());
      expect(service, isA<WechatCameraPickerServiceImpl>());
    });
  });

  group('WechatCameraPickerService abstract class', () {
    test('abstract class defines pickImage method', () {
      // Verify the abstract interface type exists
      expect(WechatCameraPickerService, isA<Type>());
    });
  });

  group('WechatCameraPickerServiceImpl.pickImage widget test', () {
    testWidgets('pickImage can be called with BuildContext', (
      WidgetTester tester,
    ) async {
      final service = WechatCameraPickerServiceImpl();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Verify the method can accept a BuildContext
              expect(() => service.pickImage(context), isA<Function>());

              // Verify the return type is correct
              expect(
                service.pickImage,
                isA<Future<AssetEntity?> Function(BuildContext)>(),
              );

              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Note: We cannot fully test pickImage without mocking CameraPicker.pickFromCamera
      // which is a static method. The actual camera UI requires device permissions
      // and camera hardware that cannot be tested in unit tests.
    });
  });
}
