import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'novel/create_novel_screen.dart';
import 'profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const BookmarksScreen(),
      CreateNovelScreen(
        onCancel: () => _switchTab(0),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        height: 68,
        indicatorColor: AppTheme.primary.withOpacity(0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.primary),
            label: 'สำรวจ',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark_rounded, color: AppTheme.primary),
            label: 'ชั้นหนังสือ',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_rounded, color: AppTheme.primary),
            label: 'แต่งนิยาย',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
