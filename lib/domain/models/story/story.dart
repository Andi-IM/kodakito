import 'package:freezed_annotation/freezed_annotation.dart';
part 'story.freezed.dart';
part 'story.g.dart';

@freezed
abstract class Story with _$Story {
  const factory Story({
    /// e.g. 'story-FvU4u0Vp2S3PMsFg'
    required String id,

    /// e.g. 'Dimas'
    required String name,

    /// e.g. 'Lorem Ipsum'
    required String description,

    /// e.g. 'https://story-api.dicoding.dev/images/stories/photos-1641623658595_dummy-pic.png'
    required String photoUrl,

    /// e.g. '2022-01-01T00:00:00.000Z'
    required DateTime createdAt,

    /// e.g. 12.5
    required double? lat,

    /// e.g. 12.5
    required double? lon,
  }) = _Story;

  factory Story.fromJson(Map<String, Object?> json) => _$StoryFromJson(json);
}
