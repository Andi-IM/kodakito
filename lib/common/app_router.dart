import 'dart:io';

import 'package:dicoding_story/presentation/main/add_story.dart';
import 'package:dicoding_story/presentation/main/main_screen.dart';
import 'package:dicoding_story/presentation/detail/story_detail.dart';
import 'package:dicoding_story/presentation/auth/story_login.dart';
import 'package:dicoding_story/presentation/auth/story_register.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: '/login',
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
          builder: (context, state) => const MainScreen(),
          routes: [
            GoRoute(
              path: '/:id',
              name: 'detail',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return StoryDetailPage(id: id);
              },
            ),
          ],
        ),
        if (Platform.isAndroid || Platform.isIOS)
          GoRoute(
            path: '/add-story',
            name: 'add-story',
            builder: (context, state) {
              final cropStream =
                  state.extra as Stream<InstaAssetsExportDetails>;
              return AddStoryPage(cropStream: cropStream);
            },
          ),
      ],
    );
  }
}
