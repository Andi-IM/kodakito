import 'package:dicoding_story/utils/http_exception.dart';

sealed class AddStoryState {
  const AddStoryState();
}

class AddStoryInitial extends AddStoryState {
  const AddStoryInitial();
}

class AddStoryLoading extends AddStoryState {
  const AddStoryLoading();
}

class AddStorySuccess extends AddStoryState {
  const AddStorySuccess();
}

class AddStoryFailure extends AddStoryState {
  final AppException exception;
  const AddStoryFailure(this.exception);
}
