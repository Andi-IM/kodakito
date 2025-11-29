# Navigation 2.0 Implementation with GoRouter

This project uses `go_router` to implement Navigation 2.0, providing a declarative and flexible routing system.

## Overview

The routing configuration is centralized in `lib/common/app_router.dart`. It uses a `GoRouter` instance to define the application's route hierarchy, including deep linking support and nested navigation.

## Configuration

The `AppRouter` class defines the `createRouter` method, which returns the configured `GoRouter`.

```dart
// lib/common/app_router.dart

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: '/login',
      routes: [
        // ... routes defined here
      ],
    );
  }
}
```

## ShellRoute for Persistent Navigation

A key feature of this implementation is the use of `ShellRoute`. This allows for a persistent UI wrapper around child routes, which is perfect for implementing a bottom navigation bar or navigation rail that remains visible while navigating between main tabs.

```dart
// lib/common/app_router.dart

ShellRoute(
  navigatorKey: _shellKey,
  builder: (context, state, child) => MainNavigation(child: child),
  routes: [
    GoRoute(
      path: '/',
      name: 'main',
      builder: (context, state) => const MainScreen(),
      routes: [
        GoRoute(
          path: 'bookmark',
          name: 'bookmark',
          builder: (context, state) => const BookmarkScreen(),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: ':id',
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
```

In this setup:
-   `MainNavigation` is the wrapper widget containing the `NavigationRail` or `NavigationBar`.
-   The `child` passed to `MainNavigation` is the widget for the current route (e.g., `MainScreen`, `BookmarkScreen`).

## Navigation Commands

Navigation is performed using `context.go()` for replacing the current stack or `context.push()` for adding to the stack.

```dart
// Example: Navigating to a story detail page
context.push('/story_detail', extra: story);

// Example: Switching tabs
context.go('/bookmark');
```

## Type-Safe Parameters

Parameters can be passed via path parameters or the `extra` object.

```dart
// Defining a route with a parameter
GoRoute(
  path: ':id',
  name: 'detail',
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return StoryDetailPage(id: id);
  },
),
```
