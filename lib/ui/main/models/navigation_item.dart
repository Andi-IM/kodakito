import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final IconData iconOutlined;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.iconOutlined,
    required this.route,
  });
}

const List<NavigationItem> navigationItems = [
  NavigationItem(
    title: 'Home',
    icon: Icons.home,
    iconOutlined: Icons.home_outlined,
    route: '/',
  ),
  NavigationItem(
    title: 'Saved',
    icon: Icons.favorite,
    iconOutlined: Icons.favorite_border_outlined,
    route: '/bookmark',
  ),
  NavigationItem(
    title: 'Profile',
    icon: Icons.person,
    iconOutlined: Icons.person_outlined,
    route: '/profile',
  ),
];
