import 'package:dicoding_story/presentation/bookmark/bookmark_screen.dart';
import 'package:dicoding_story/presentation/main/main_screen.dart';
import 'package:dicoding_story/presentation/detail/story_detail.dart';
import 'package:dicoding_story/presentation/auth/story_login.dart';
import 'package:dicoding_story/presentation/auth/story_register.dart';
import 'package:dicoding_story/presentation/main/widgets/main_navigation.dart';
import 'package:dicoding_story/presentation/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellKey = GlobalKey<NavigatorState>();

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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigation(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: _shellKey,
              routes: [
                GoRoute(
                  path: '/',
                  name: 'main',
                  builder: (context, state) => const MainScreen(),
                  routes: [
                    GoRoute(
                      path: 'story/:id',
                      name: 'detail',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return StoryDetailPage(id: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/bookmark',
                  name: 'bookmark',
                  builder: (context, state) => const BookmarkScreen(),
                  routes: [
                    GoRoute(
                      path: 'story/:id',
                      name: 'bookmark_detail',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return StoryDetailPage(id: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
