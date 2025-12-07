import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

part 'wechat_camera_picker_service.g.dart';

@riverpod
WechatCameraPickerService cameraPickerService(Ref ref) =>
    WechatCameraPickerServiceImpl();

abstract class WechatCameraPickerService {
  Future<AssetEntity?> pickImage(BuildContext context);
}

class WechatCameraPickerServiceImpl implements WechatCameraPickerService {
  ResolutionPreset get cameraResolutionPreset =>
      Platform.isAndroid ? ResolutionPreset.high : ResolutionPreset.max;

  @override
  Future<AssetEntity?> pickImage(BuildContext context) async {
    return await CameraPicker.pickFromCamera(
      context,
      locale: Localizations.maybeLocaleOf(context),
      pickerConfig: CameraPickerConfig(
        theme: Theme.of(context),
        resolutionPreset: cameraResolutionPreset,
        enableRecording: false,
      ),
    );
  }
}
