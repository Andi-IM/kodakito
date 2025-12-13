import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/l10n/app_asset_picker_text_delegate.dart';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insta_image_picker_service.g.dart';

@riverpod
InstaImagePickerService instaImagePickerService(Ref ref) =>
    InstaImagePickerServiceImpl();

abstract class InstaImagePickerService {
  Future<void> pickImage(
    BuildContext context,
    Function(BuildContext context) pickFromCamera,
    Function(Stream<InstaAssetsExportDetails>) onCompleted,
  );

  // coverage:ignore-start
  Future<void> refreshAndSelectEntity(
    BuildContext context,
    AssetEntity entity,
  ) async {
    await InstaAssetPicker.refreshAndSelectEntity(context, entity);
  }

  // coverage:ignore-end
}

// coverage:ignore-start
class InstaImagePickerServiceImpl implements InstaImagePickerService {
  @override
  Future<void> pickImage(
    BuildContext context,
    Function(BuildContext context) pickFromCamera,
    Function(Stream<InstaAssetsExportDetails>) onCompleted,
  ) async {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final appBarTheme = AppBarTheme(
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(color: primaryColor),
    );
    final pickerTheme = InstaAssetPicker.themeData(
      primaryColor,
    ).copyWith(appBarTheme: appBarTheme);
    InstaAssetPicker.pickAssets(
      context,
      pickerConfig: InstaAssetPickerConfig(
        title: context.l10n.addStoryTitle,
        closeOnComplete: true,
        textDelegate: context.l10n.localeName == 'id'
            ? IndonesianAssetPickerTextDelegate()
            : null,
        pickerTheme: pickerTheme,
        actionsBuilder: (context, theme, height, unselectAll) => [
          InstaPickerCircleIconButton.unselectAll(
            onTap: unselectAll,
            theme: theme,
            size: height,
          ),
        ],
        specialItemBuilder: (context, _, __) {
          return Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: IconButton(
              onPressed: () => pickFromCamera(context),
              icon: const Icon(Icons.camera_alt),
            ),
          );
        },
        specialItemPosition: SpecialItemPosition.prepend,
      ),
      maxAssets: 1,
      onCompleted: onCompleted,
    );
  }

  @override
  Future<void> refreshAndSelectEntity(
    BuildContext context,
    AssetEntity entity,
  ) {
    return InstaAssetPicker.refreshAndSelectEntity(context, entity);
  }
}

// coverage:ignore-end
