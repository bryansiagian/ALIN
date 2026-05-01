import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/screen/lecturer_dashboard_screen.dart';
import 'package:flutter_math/features/exam/screen/student_list_screen.dart';

class MainLecturerScreen extends StatefulWidget {
  const MainLecturerScreen({super.key});

  @override
  State<MainLecturerScreen> createState() => _MainLecturerScreenState();
}

class _MainLecturerScreenState extends State<MainLecturerScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const LecturerDashboardScreen(), // Halaman Kuis (yang sudah Anda punya)
    const StudentListScreen(),      // Halaman Mahasiswa (Langkah 3)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "Manajemen Kuis" : "Daftar Mahasiswa"),
        actions: [
          // INI TOMBOL LOGOUT ANDA YANG KEMBALI
          Consumer(builder: (context, ref, child) {
            return IconButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
            );
          }),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Kuis"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Mahasiswa"),
        ],
      ),
    );
  }
}