import 'package:dicoding_story/presentation/main/models/navigation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:window_size_classes/window_size_classes.dart';

class MainNavigation extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainNavigation({super.key, required this.navigationShell});

  void onDestinationSelected(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = WindowWidthClass.of(context) <= WindowWidthClass.compact;
    // final fullPath = GoRouterState.of(context).fullPath;
    // final showNavigation = navigationItems.any(
    //   (element) => fullPath == element.route,
    // );
    // final matchedLocation = GoRouterState.of(context).matchedLocation;
    // final selectedIndex = navigationItems
    //     .map((item) => matchedLocation == item.route)
    //     .toList()
    //     .asMap()
    //     .entries
    //     .firstWhere(
    //       (entry) => entry.value,
    //       orElse: () => const MapEntry(0, false),
    //     )
    //     .key;
    final selectedIndex = navigationShell.currentIndex;

    return Scaffold(
      body: (!isCompact)
          ? Row(
              children: [
                NavigationRailM3E(
                  type: NavigationRailM3EType.alwaysCollapse,
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
                  sections: [
                    NavigationRailM3ESection(
                      destinations: navigationItems
                          .map(
                            (item) => NavigationRailM3EDestination(
                              icon: Icon(item.iconOutlined),
                              selectedIcon: Icon(item.icon),
                              label: item.title,
                              short: true,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      onDestinationSelected(context, index),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: navigationShell,
                  ),
                ),
              ],
            )
          : navigationShell,
      bottomNavigationBar: (isCompact)
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
