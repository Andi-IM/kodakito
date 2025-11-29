# Material 3 Expressive Design Implementation

This project embraces Material 3 design principles to create a modern, adaptive, and expressive user interface.

## Material 3 Theme

The application uses a comprehensive Material 3 theme defined in `lib/common/theme.dart`. The `MaterialTheme` class manages color schemes for light and dark modes, as well as high and medium contrast variants.

To enable Material 3, `useMaterial3: true` is set in the `ThemeData`.

```dart
// lib/common/theme.dart

ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     // ... other properties
);
```

In `lib/main.dart`, the theme is applied to the `MaterialApp`:

```dart
// lib/main.dart

MaterialTheme theme = MaterialTheme(textTheme);

return MaterialApp.router(
  // ...
  theme: theme.light(),
  // theme: theme.dark(), // For dark mode
);
```

## Adaptive Navigation

The app adapts its navigation layout based on the screen size, ensuring an optimal experience on mobile, tablet, and desktop. This is handled in `lib/presentation/main/widgets/main_navigation.dart`.

We use the `window_size_classes` package to determine the screen width class.

### Mobile Layout (< 600dp)

For compact screens, a standard `NavigationBar` is used at the bottom.

```dart
// lib/presentation/main/widgets/main_navigation.dart

bottomNavigationBar: (isCompact && showNavigation)
    ? NavigationBar(
        destinations: navigationItems
            .map((item) => NavigationDestination(...))
            .toList(),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => onDestinationSelected(context, index),
      )
    : null,
```

### Tablet/Desktop Layout (>= 600dp)

For medium and expanded screens, a `NavigationRailM3E` (Material 3 Expressive Navigation Rail) is used on the side. This rail supports expanded and collapsed states.

```dart
// lib/presentation/main/widgets/main_navigation.dart

NavigationRailM3E(
  fab: NavigationRailM3EFabSlot(...), // Floating Action Button in Rail
  type: isExpanded
      ? NavigationRailM3EType.collapsed
      : NavigationRailM3EType.expanded,
  sections: [
    NavigationRailM3ESection(
      header: Text('Main'),
      destinations: navigationItems
          .map((item) => NavigationRailM3EDestination(...))
          .toList(),
    ),
  ],
  selectedIndex: selectedIndex,
  onDestinationSelected: (index) => onDestinationSelected(context, index),
),
```

## Responsive Layouts

Screens also adapt their internal layout. For example, `MainScreen` switches between a `ListView` and a `GridView` depending on the available width.

```dart
// lib/presentation/main/main_screen.dart

final widthClass = WindowWidthClass.of(context);

if (widthClass >= WindowWidthClass.medium) {
  // Show GridView for larger screens
  scrollableWidget = GridView.builder(...);
} else {
  // Show ListView for mobile screens
  scrollableWidget = ListView.builder(...);
}
```
