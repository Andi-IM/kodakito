import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/utils/http_exception.dart';

/// Repository for adding new stories
abstract class AddStoryRepository {
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    Uint8List photoBytes, {
    double? lat,
    double? lon,
  });
}
