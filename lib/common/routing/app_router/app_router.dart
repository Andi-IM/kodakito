import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/common/routing/dialog_page.dart';
import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/auth/widgets/login_page.dart';
import 'package:dicoding_story/ui/auth/widgets/register_page.dart';
import 'package:dicoding_story/ui/detail/widgets/free/story_detail_page.dart';
import 'package:dicoding_story/ui/detail/widgets/pro/story_detail_page_pro.dart'
    show StoryDetailPagePro;
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/compact/add_story.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/compact/location_picker_page.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_dialog.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/story_crop_dialog.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/ui/main/widgets/settings_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

// =============================================================================
// Route Names (Type-safe constants)
// =============================================================================

abstract class AppRoutes {
  static const String login = 'login';
  static const String register = 'register';
  static const String main = 'main';
  static const String settings = 'settings';
  static const String language = 'language';
  static const String addStory = 'add-story';
  static const String addStoryCrop = 'add-story-crop';
  static const String detail = 'detail';
  static const String mobileCrop = 'mobile-crop';
  static const String locationPicker = 'location-picker';
}

// =============================================================================
// Type-safe Route Navigation Extensions
// =============================================================================

extension AppRouterExtension on BuildContext {
  /// Navigate to login page
  void goToLogin() => goNamed(AppRoutes.login);

  /// Navigate to register page
  void goToRegister() => goNamed(AppRoutes.register);

  /// Navigate to main page
  void goToMain() => goNamed(AppRoutes.main);

  /// Push main page (replacement)
  void pushReplacementMain() => pushReplacementNamed(AppRoutes.main);

  /// Navigate to settings dialog
  void goToSettings() => goNamed(AppRoutes.settings);

  /// Navigate to language dialog
  void goToLanguage() => goNamed(AppRoutes.language);

  /// Navigate to add story dialog
  void goToAddStory() => goNamed(AppRoutes.addStory);

  /// Navigate to add story crop dialog with image bytes
  void goToAddStoryCrop(Uint8List imageBytes) =>
      goNamed(AppRoutes.addStoryCrop, extra: imageBytes);

  /// Navigate to story detail page
  void goToDetail({required String id, bool hasLocation = false}) => goNamed(
    AppRoutes.detail,
    pathParameters: {'id': id},
    queryParameters: {'hasLocation': hasLocation.toString()},
  );

  /// Navigate to mobile crop page with stream
  void goToMobileCrop(Stream<InstaAssetsExportDetails> cropStream) =>
      goNamed(AppRoutes.mobileCrop, extra: cropStream);

  /// Navigate to location picker and return selected location
  Future<PlaceInfo?> pushLocationPicker({PlaceInfo? initialLocation}) async {
    return await pushNamed<PlaceInfo>(
      AppRoutes.locationPicker,
      extra: initialLocation,
    );
  }
}

// =============================================================================
// Router Provider
// =============================================================================

@riverpod
GoRouter appRouter(Ref ref) {
  final isProEnvironment =
      EnvInfo.environment == AppEnvironment.pro ||
      EnvInfo.environment == AppEnvironment.proDevelopment;

  return GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: '/login',
    redirect: (context, state) async {
      final cacheRepository = ref.read(cacheRepositoryProvider);
      final hasToken = await cacheRepository.hasToken();
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';

      if (hasToken && (isLoggingIn || isRegistering)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => LoginPage(
          goToRegister: () => context.goToRegister(),
          onLoginSuccess: () => context.pushReplacementMain(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => RegisterPage(
          onRegisterSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.authRegisterSuccessMessage)),
            );
            context.goToLogin();
          },
          goToLogin: () => context.goToLogin(),
        ),
      ),
      GoRoute(
        path: '/',
        name: AppRoutes.main,
        builder: (context, state) => const MainPage(),
        routes: [
          GoRoute(
            path: 'settings',
            name: AppRoutes.settings,
            pageBuilder: (context, state) {
              return DialogPage(
                builder: (_) => SettingsDialog(
                  onPop: () => context.pop(),
                  onLogout: () => context.goToLogin(),
                  onLanguageDialogOpen: () => context.goToLanguage(),
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'language',
                name: AppRoutes.language,
                pageBuilder: (context, state) {
                  return DialogPage(
                    builder: (_) => LanguageDialog(onPop: () => context.pop()),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'add-story',
            name: AppRoutes.addStory,
            pageBuilder: (context, state) {
              return DialogPage(builder: (_) => const AddStoryDialog());
            },
            routes: [
              GoRoute(
                path: 'crop',
                name: AppRoutes.addStoryCrop,
                pageBuilder: (context, state) => DialogPage(
                  builder: (context) {
                    final imageBytes = state.extra as Uint8List;
                    return StoryCropDialog(
                      imageBytes: imageBytes,
                      cropController: CropController(),
                      onPop: () => context.pop(),
                    );
                  },
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'story/:id',
            name: AppRoutes.detail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final hasLocation =
                  state.uri.queryParameters['hasLocation'] == 'true';

              return Consumer(
                builder: (context, ref, child) {
                  final isSupport = ref.watch(supportMapsProvider);
                  final showProDetail =
                      isProEnvironment && isSupport && hasLocation;

                  if (showProDetail) {
                    return StoryDetailPagePro(
                      id: id,
                      onBack: () => context.pop(),
                    );
                  }

                  return StoryDetailPage(id: id);
                },
              );
            },
          ),
        ],
      ),

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        GoRoute(
          path: '/crop',
          name: AppRoutes.mobileCrop,
          builder: (context, state) {
            final cropStream = state.extra as Stream<InstaAssetsExportDetails>;
            return AddStoryPage(
              cropStream: cropStream,
              onAddStorySuccess: () {
                ref.read(addStoryProvider.notifier).resetState();
                context.pushReplacementMain();
              },
            );
          },
        ),

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        GoRoute(
          path: '/location-picker',
          name: AppRoutes.locationPicker,
          builder: (context, state) {
            final initialLocation = state.extra as PlaceInfo?;
            return LocationPickerPage(initialLocation: initialLocation);
          },
        ),
    ],
  );
}
