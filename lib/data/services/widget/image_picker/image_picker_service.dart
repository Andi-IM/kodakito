import 'dart:typed_data' show Uint8List;

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_picker_service.g.dart';

@riverpod
ImagePickerService imagePickerService(Ref ref) => ImagePickerServiceImpl();

abstract class ImagePickerService {
  Future<Uint8List?> pickImage({ImageSource source = ImageSource.gallery});
}

// coverage:ignore-start
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<Uint8List?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final pickedImage = await _picker.pickImage(source: source);
    return pickedImage?.readAsBytes();
  }
}

// coverage:ignore-end
