import 'dart:typed_data';

import 'package:dicoding_story/data/services/widget/image_picker/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

/// Testable version of ImagePickerServiceImpl that accepts an ImagePicker
class TestableImagePickerService implements ImagePickerService {
  final ImagePicker picker;

  TestableImagePickerService(this.picker);

  @override
  Future<Uint8List?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final pickedImage = await picker.pickImage(source: source);
    return pickedImage?.readAsBytes();
  }
}

void main() {
  late MockImagePicker mockPicker;
  late TestableImagePickerService service;

  setUp(() {
    mockPicker = MockImagePicker();
    service = TestableImagePickerService(mockPicker);
  });

  group('ImagePickerServiceImpl', () {
    test(
      'pickImage returns Uint8List when image is picked from gallery',
      () async {
        // Arrange
        final mockXFile = MockXFile();
        final expectedBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(
          () => mockPicker.pickImage(source: ImageSource.gallery),
        ).thenAnswer((_) async => mockXFile);
        when(
          () => mockXFile.readAsBytes(),
        ).thenAnswer((_) async => expectedBytes);

        // Act
        final result = await service.pickImage();

        // Assert
        expect(result, expectedBytes);
        verify(
          () => mockPicker.pickImage(source: ImageSource.gallery),
        ).called(1);
        verify(() => mockXFile.readAsBytes()).called(1);
      },
    );

    test(
      'pickImage returns Uint8List when image is picked from camera',
      () async {
        // Arrange
        final mockXFile = MockXFile();
        final expectedBytes = Uint8List.fromList([10, 20, 30]);

        when(
          () => mockPicker.pickImage(source: ImageSource.camera),
        ).thenAnswer((_) async => mockXFile);
        when(
          () => mockXFile.readAsBytes(),
        ).thenAnswer((_) async => expectedBytes);

        // Act
        final result = await service.pickImage(source: ImageSource.camera);

        // Assert
        expect(result, expectedBytes);
        verify(
          () => mockPicker.pickImage(source: ImageSource.camera),
        ).called(1);
        verify(() => mockXFile.readAsBytes()).called(1);
      },
    );

    test('pickImage returns null when no image is picked', () async {
      // Arrange
      when(
        () => mockPicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      // Act
      final result = await service.pickImage();

      // Assert
      expect(result, isNull);
      verify(() => mockPicker.pickImage(source: ImageSource.gallery)).called(1);
    });

    test('pickImage uses gallery as default source', () async {
      // Arrange
      when(
        () => mockPicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      // Act
      await service.pickImage();

      // Assert
      verify(() => mockPicker.pickImage(source: ImageSource.gallery)).called(1);
      verifyNever(() => mockPicker.pickImage(source: ImageSource.camera));
    });
  });

  group('ImagePickerServiceImpl real instance', () {
    test('creates instance correctly', () {
      // Verify the real implementation can be instantiated
      final realService = ImagePickerServiceImpl();
      expect(realService, isA<ImagePickerService>());
    });
  });
}
