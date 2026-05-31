import 'package:flutter/material.dart';
import 'feed/feed_screen.dart';
import 'communities/communities_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    FeedScreen(),
    CommunitiesScreen(),
    ProfileScreen(),
  ];

  static const _labels = ['Feed', 'Comunidades', 'Perfil'];
  static const _icons = [
    Icons.home_outlined,
    Icons.group_outlined,
    Icons.person_outlined,
  ];
  static const _activeIcons = [
    Icons.home,
    Icons.group,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: List.generate(
          _labels.length,
          (i) => NavigationDestination(
            icon: Icon(_icons[i]),
            selectedIcon: Icon(_activeIcons[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}
