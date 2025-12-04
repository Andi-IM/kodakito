import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/utils/http_exception.dart';

abstract class AddStoryRepository {
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    File photo, {
    double? lat,
    double? lon,
  });
}
