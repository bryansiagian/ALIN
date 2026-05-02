import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Wajib ada
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/screen/lecturer_dashboard_screen.dart';
import 'package:flutter_math/features/exam/screen/student_list_screen.dart';
import 'package:flutter_math/features/exam/screen/upload_material_screen.dart';

// 1. Ubah StatefulWidget menjadi ConsumerStatefulWidget
class MainLecturerScreen extends ConsumerStatefulWidget {
  const MainLecturerScreen({super.key});

  @override
  ConsumerState<MainLecturerScreen> createState() => _MainLecturerScreenState();
}

// 2. Ubah State menjadi ConsumerState
class _MainLecturerScreenState extends ConsumerState<MainLecturerScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const LecturerDashboardScreen(), 
    const StudentListScreen(),      
    const Center(child: Text("Halaman Manajemen Materi")), // Placeholder Tab Materi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 
              ? "Manajemen Kuis" 
              : _currentIndex == 1 
                  ? "Daftar Mahasiswa" 
                  : "Manajemen Materi"
        ),
        actions: [
          // Tombol Khusus Upload muncul hanya di Tab Materi
          if (_currentIndex == 2)
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (c) => const UploadMaterialScreen())
              ),
            ),
          
          // TOMBOL LOGOUT (Sekarang 'ref' sudah dikenal)
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(), 
            icon: const Icon(Icons.logout)
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Kuis"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Mahasiswa"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Materi"),
        ],
      ),
    );
  }
}