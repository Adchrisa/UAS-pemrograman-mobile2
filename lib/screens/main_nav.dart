import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'daily_tips_screen.dart';
import 'tracker_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    DailyTipsScreen(),
    TrackerScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('✅ MainNav initialized');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 MainNav building, current index: $_currentIndex');
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Daily Tips'),
          BottomNavigationBarItem(icon: Icon(Icons.park), label: 'My Garden'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
