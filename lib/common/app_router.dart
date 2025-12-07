import 'dart:io';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/compact/add_story.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_page.dart';
import 'package:dicoding_story/ui/auth/widgets/login_page.dart';
import 'package:dicoding_story/ui/auth/widgets/register_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        return '/story';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(
          goToRegister: () => context.go('/register'),
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
        path: '/story',
        name: 'main',
        builder: (context, state) => const MainPage(),
        routes: [
          GoRoute(
            path: '/:id',
            name: 'detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StoryDetailPage(id: id);
            },
          ),
        ],
      ),
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        GoRoute(
          path: '/add-story',
          name: 'add-story',
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
