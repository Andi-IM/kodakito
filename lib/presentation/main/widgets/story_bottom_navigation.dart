import 'package:dicoding_story/presentation/main/models/navigation_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoryBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  const StoryBottomNavigation({super.key, required this.selectedIndex});

  @override
  State<StoryBottomNavigation> createState() => _StoryBottomNavigationState();
}

class _StoryBottomNavigationState extends State<StoryBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: _slideAnimation,
      child: NavigationBar(
        indicatorColor: theme.colorScheme.primary,
        destinations: navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.title,
              ),
            )
            .toList(),
        
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: (index) =>
            context.go(navigationItems[index].route),
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}
