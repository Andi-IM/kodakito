import 'package:dicoding_story/app/app_env.dart';
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'STORY_URL')
  static final String storyUrl = _Env.storyUrl;

  @EnviedField(varName: 'STORY_ENV')
  static final String storyEnv = _Env.storyEnv;

  static AppEnvironment get appEnvironment => AppEnvironment.values.firstWhere(
    (e) => e.name == storyEnv,
    orElse: () => AppEnvironment.development,
  );
}
