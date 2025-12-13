import 'package:dicoding_story/common/routing/app_router/go_router_builder.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    routes: $appRoutes,
  );
}
