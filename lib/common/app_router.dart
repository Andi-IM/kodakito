import 'dart:io';

import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/main/widgets/add_story.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail.dart';
import 'package:dicoding_story/ui/auth/widgets/login_page.dart';
import 'package:dicoding_story/ui/auth/widgets/register_page.dart';
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
        return '/story';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
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
            return AddStoryPage(cropStream: cropStream);
          },
        ),
    ],
  );
}
