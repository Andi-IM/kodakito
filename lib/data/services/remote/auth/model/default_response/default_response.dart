import 'package:freezed_annotation/freezed_annotation.dart';

part 'default_response.freezed.dart';
part 'default_response.g.dart';

@freezed
abstract class DefaultResponse with _$DefaultResponse {
  const factory DefaultResponse({
    required bool error,
    required String message,
  }) = _DefaultResponse;

  factory DefaultResponse.fromJson(Map<String, Object?> json) =>
      _$DefaultResponseFromJson(json);
}