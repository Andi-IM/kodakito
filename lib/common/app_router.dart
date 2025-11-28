import 'package:dicoding_story/data/model/story.dart';
import 'package:dicoding_story/presentation/pages/story_detail.dart';
import 'package:dicoding_story/presentation/pages/story_list.dart';
import 'package:dicoding_story/presentation/pages/story_login.dart';
import 'package:dicoding_story/presentation/pages/story_register.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(title: 'Story List'),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            final story = state.extra as Story;
            return StoryDetailPage(story: story);
          },
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    );
  }
}
