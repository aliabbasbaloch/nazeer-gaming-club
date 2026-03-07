import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import 'providers/draw_provider.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/draw/draw_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    DrawScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) setState(() => _currentIndex = index);
  }

  void _navigateToHome() {
    setState(() => _currentIndex = 0);
  }

  Future<void> _addDrawnPlayersToGame(List<String> names) async {
    // Create a new game with the drawn players
    final settingsNotifier = ref.read(settingsProvider);
    await ref.read(gameProvider.notifier).createNewGame(
      targetScore: settingsNotifier.defaultTargetScore,
    );
    // Add each player in drawn order
    for (final name in names) {
      await ref.read(gameProvider.notifier).addPlayer(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for navigation request from Draw screen
    ref.listen<bool>(navigateToHomeProvider, (prev, next) {
      if (next) {
        // Get drawn names and add to game
        final drawData = ref.read(drawProvider);
        if (drawData.drawState == DrawState.complete) {
          _addDrawnPlayersToGame(drawData.drawnNames);
        }
        // Reset the draw screen
        ref.read(drawProvider.notifier).reset();
        // Reset the navigation flag
        ref.read(navigateToHomeProvider.notifier).state = false;
        // Navigate to Home tab
        _navigateToHome();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navbar,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Draw'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
