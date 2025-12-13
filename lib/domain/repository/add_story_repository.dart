import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:image_picker/image_picker.dart';

/// Repository for adding new stories
abstract class AddStoryRepository {
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    XFile photoFile, {
    double? lat,
    double? lon,
  });
}
