import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/common/routing/dialog_page.dart';
import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/ui/auth/widgets/login_screen.dart';
import 'package:dicoding_story/ui/auth/widgets/register_page.dart';
import 'package:dicoding_story/ui/detail/widgets/free/story_detail_screen.dart';
import 'package:dicoding_story/ui/detail/widgets/pro/story_detail_screen_pro.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/compact/add_story.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/compact/location_picker_page.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/wide/add_story_dialog.dart';
import 'package:dicoding_story/ui/home/widgets/add_story/wide/story_crop_dialog.dart';
import 'package:dicoding_story/ui/home/widgets/home_screen.dart';
import 'package:dicoding_story/ui/home/widgets/settings_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:logging/logging.dart';

part 'go_router_builder.g.dart';

final _log = Logger('AppRouter');

abstract class Routing {
  static const String home = 'home';
  static const String detail = 'detail';
  static const String post = 'post';
  static const String crop = 'crop';
  static const String pickLocation = 'pick-location';
  static const String login = 'login';
  static const String register = 'register';
  static const String settings = 'settings';
  static const String language = 'language';
}

@TypedGoRoute<HomeScreenRoute>(
  path: '/',
  name: Routing.home,
  routes: [
    TypedGoRoute<DetailRoute>(path: 'story/:id', name: Routing.detail),
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
      name: Routing.settings,
      routes: [
        TypedGoRoute<LanguageRoute>(path: 'language', name: Routing.language),
      ],
    ),
    TypedGoRoute<PostStoryRoute>(
      path: 'post',
      name: Routing.post,
      routes: [
        TypedGoRoute<CropStoryImageRoute>(path: 'crop', name: Routing.crop),
        TypedGoRoute<LocationPickerRoute>(
          path: 'pick-location',
          name: Routing.pickLocation,
        ),
      ],
    ),
  ],
)
@immutable
class HomeScreenRoute extends GoRouteData with $HomeScreenRoute {
  const HomeScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    _log.info('Navigating to HomeScreen');
    return const HomeScreen();
  }
}

@immutable
class DetailRoute extends GoRouteData with $DetailRoute {
  final String id;
  final bool hasLocation;

  const DetailRoute({required this.id, this.hasLocation = false});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    _log.info('Navigating to DetailRoute: id=$id, hasLocation=$hasLocation');
    final isProEnvironment =
        EnvInfo.environment == AppEnvironment.pro ||
        EnvInfo.environment == AppEnvironment.proDevelopment;

    return Consumer(
      builder: (context, ref, child) {
        final isSuport = ref.watch(supportMapsProvider);
        final showProDetail = isProEnvironment && isSuport && hasLocation;
        if (showProDetail) {
          _log.info('Showing StoryDetailScreenPro');
          return StoryDetailScreenPro(id: id, onBack: () => context.pop());
        }
        _log.info('Showing StoryDetailScreen');
        return StoryDetailScreen(id: id);
      },
    );
  }
}

@immutable
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Page<void> buildPage(_, state) {
    _log.info('Navigating to SettingsRoute');
    return DialogPage(
      builder: (context) => SettingsDialog(
        onPop: () => context.pop(),
        onLogout: () => context.pushReplacementNamed(Routing.login),
        onLanguageDialogOpen: () => context.goNamed(Routing.language),
      ),
    );
  }
}

@immutable
class LanguageRoute extends GoRouteData with $LanguageRoute {
  const LanguageRoute();

  @override
  Page<void> buildPage(_, state) {
    _log.info('Navigating to LanguageRoute');
    return DialogPage(
      builder: (context) => LanguageDialog(onPop: () => context.pop()),
    );
  }
}

/// Extra data class for PostStoryRoute
class PostStoryRouteExtra {
  final Stream<InstaAssetsExportDetails>? cropStream;

  const PostStoryRouteExtra({this.cropStream});
}

@immutable
class PostStoryRoute extends GoRouteData with $PostStoryRoute {
  const PostStoryRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    _log.info('Navigating to PostStoryRoute');
    final extra = state.extra as PostStoryRouteExtra?;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _log.info('Building AddStoryPage (mobile)');
      final cropStream = extra?.cropStream;
      return MaterialPage(
        child: AddStoryPage(
          cropStream: cropStream!,
          onAddStorySuccess: () {
            context.go('/');
          },
        ),
      );
    }
    _log.info('Building AddStoryDialog (desktop)');
    return DialogPage(builder: (_) => const AddStoryDialog());
  }
}

@immutable
class CropStoryImageRoute extends GoRouteData with $CropStoryImageRoute {
  const CropStoryImageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    _log.info('Navigating to CropStoryImageRoute');
    final imageBytes = state.extra as Uint8List;
    return MaterialPage(
      child: StoryCropDialog(
        imageBytes: imageBytes,
        cropController: CropController(),
        onPop: () => context.pop(),
      ),
    );
  }
}

@immutable
class LocationPickerRoute extends GoRouteData with $LocationPickerRoute {
  const LocationPickerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    _log.info('Navigating to LocationPickerRoute');
    final initialLocation = state.extra as PlaceInfo?;
    return LocationPickerPage(initialLocation: initialLocation);
  }
}

@TypedGoRoute<LoginRoute>(
  path: '/login',
  name: Routing.login,
  routes: [
    TypedGoRoute<RegisterRoute>(path: 'register', name: Routing.register),
  ],
)
@immutable
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    _log.info('Navigating to LoginRoute');
    return LoginScreen(
      goToRegister: () => context.goNamed(Routing.register),
      onLoginSuccess: () => context.goNamed(Routing.home),
    );
  }
}

@immutable
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    _log.info('Navigating to RegisterRoute');
    return RegisterScreen(
      goToLogin: () => context.go(Routing.login),
      onRegisterSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register success, please login')),
        );
        context.pop();
      },
    );
  }
}
