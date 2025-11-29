import 'package:dicoding_story/presentation/main/models/navigation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_rail_m3e/navigation_rail_m3e.dart';
import 'package:window_size_classes/window_size_classes.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  void onDestinationSelected(BuildContext context, int index) {
    context.go(navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = WindowWidthClass.of(context) <= WindowWidthClass.compact;
    final isExpanded = WindowWidthClass.of(context) >= WindowWidthClass.medium;
    final fullPath = GoRouterState.of(context).fullPath;
    final showNavigation = navigationItems.any(
      (element) => fullPath == element.route,
    );
    final matchedLocation = GoRouterState.of(context).matchedLocation;
    final selectedIndex = navigationItems
        .map((item) => matchedLocation == item.route)
        .toList()
        .asMap()
        .entries
        .firstWhere(
          (entry) => entry.value,
          orElse: () => const MapEntry(0, false),
        )
        .key;

    return Scaffold(
      body: (!isCompact && showNavigation)
          ? Row(
              children: [
                NavigationRailM3E(
                  fab: NavigationRailM3EFabSlot(
                    icon: const Icon(Icons.add),
                    label: 'Create',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('AlertDialog Title'),
                            content: const SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('This is a demo alert dialog.'),
                                  Text(
                                    'Would you like to approve of this message?',
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Approve'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  type: isExpanded
                      ? NavigationRailM3EType.collapsed
                      : NavigationRailM3EType.expanded,
                  modality: NavigationRailM3EModality.standard,
                  sections: [
                    NavigationRailM3ESection(
                      header: Text('Main'),
                      destinations: navigationItems
                          .map(
                            (item) => NavigationRailM3EDestination(
                              icon: Icon(item.iconOutlined),
                              selectedIcon: Icon(item.icon),
                              label: item.title,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      onDestinationSelected(context, index),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: (isCompact && showNavigation)
          ? NavigationBar(
              destinations: navigationItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.iconOutlined),
                      selectedIcon: Icon(item.icon),
                      label: item.title,
                    ),
                  )
                  .toList(),
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  onDestinationSelected(context, index),
            )
          : null,
    );
  }
}
