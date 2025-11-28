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
          path: '/story_list',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const StoryListPage(title: 'Story List'),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            );
          },
        ),
        GoRoute(
          path: '/story_detail',
          builder: (context, state) => const StoryDetailPage(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const LoginPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            );
          },
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const RegisterPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            );
          },
        ),
      ],
    );
  }
}
