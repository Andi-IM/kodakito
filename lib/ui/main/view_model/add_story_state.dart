import 'package:dicoding_story/utils/http_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_story_state.freezed.dart';

@freezed
abstract class AddStoryState with _$AddStoryState {
  const factory AddStoryState.initial() = Initial;
  const factory AddStoryState.loading() = Loading;
  const factory AddStoryState.success() = Loaded;
  const factory AddStoryState.failure(AppException exception) = Failure;
}
