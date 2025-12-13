import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'story_detail_pro_view_model.g.dart';

/// Provider for managing the bottom sheet extent in StoryDetailScreenPro.
@riverpod
class SheetExtent extends _$SheetExtent {
  @override
  double build() => 0.25; // Default initial extent

  /// Updates the sheet extent to a new value.
  void update(double extent) {
    state = extent;
  }
}
