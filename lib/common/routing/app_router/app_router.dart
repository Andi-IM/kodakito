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
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_dialog.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/story_crop_dialog.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/ui/main/widgets/settings_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
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
        name: 'login',
        builder: (context, state) => LoginPage(
          goToRegister: () => context.goNamed('register'),
          onLoginSuccess: () => context.pushReplacementNamed('main'),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegisterPage(
          onRegisterSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.authRegisterSuccessMessage)),
            );
            context.go('/login');
          },
          goToLogin: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainPage(),
        routes: [
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) {
              return DialogPage(
                builder: (_) => SettingsDialog(
                  onPop: () => context.pop(),
                  onLogout: () => context.goNamed('login'),
                  onLanguageDialogOpen: () => context.goNamed('language'),
                ),
              );
            },
            routes: [
              GoRoute(
                path: '/language',
                name: 'language',
                pageBuilder: (context, state) {
                  return DialogPage(
                    builder: (_) => LanguageDialog(onPop: () => context.pop()),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/add-story',
            name: 'add-story',
            pageBuilder: (context, state) {
              return DialogPage(builder: (_) => const AddStoryDialog());
            },
            routes: [
              GoRoute(
                path: '/crop',
                name: 'add-story-crop',
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
            path: '/story/:id',
            name: 'detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;

              return Consumer(
                builder: (context, ref, child) {
                  final isSupport = ref.watch(supportMapsProvider);

                  if ((EnvInfo.environment == AppEnvironment.pro ||
                          EnvInfo.environment ==
                              AppEnvironment.proDevelopment) &&
                      isSupport) {
                    return StoryDetailPagePro(id: id);
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
          name: 'mobile-crop',
          builder: (context, state) {
            final cropStream = state.extra as Stream<InstaAssetsExportDetails>;
            return AddStoryPage(
              cropStream: cropStream,
              onAddStorySuccess: () {
                ref.read(addStoryProvider.notifier).resetState();
                context.pushReplacementNamed('main');
              },
            );
          },
        ),
    ],
  );
}
