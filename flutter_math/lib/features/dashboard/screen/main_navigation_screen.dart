import 'package:flutter/material.dart';
import 'package:flutter_math/features/forum/screen/forum_feed_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/home/home_screen.dart'; // Daftar Topik
import 'package:flutter_math/features/dashboard/screen/progress_screen.dart';
import 'package:flutter_math/features/forum/screen/thread_list_screen.dart';
import 'package:flutter_math/features/gamification/screen/leaderboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang dihubungkan ke BottomNav
  final List<Widget> _screens = [
    const HomeScreen(),        // Fitur 1: Materi
    const ForumFeedScreen(),   // Fitur 10: Forum
    // const LeaderboardScreen(),  // Fitur 8: Gamifikasi
    const ProgressScreen(),     // Fitur 7: Analitik
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Materi"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
          // BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Rank"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Progres"),
        ],
      ),
    );
  }
}