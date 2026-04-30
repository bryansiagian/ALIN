import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/auth/screen/login_screen.dart';
import 'package:flutter_math/features/dashboard/screen/main_navigation_screen.dart';
import 'package:flutter_math/features/exam/screen/lecturer_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    // LOGIKA REDIRECT (PENGATUR LALU LINTAS)
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Jika BELUM login dan tidak di halaman login, paksa ke /login
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      // 2. Jika SUDAH login dan mencoba akses halaman login atau root '/'
      if (isLoggingIn || state.matchedLocation == '/') {
        if (authState.user!.role == 'lecturer') {
          return '/lecturer'; // Dosen ke sini
        }
        return '/student'; // Mahasiswa ke sini
      }

      return null;
    },
    // DAFTAR ALAMAT (WAJIB DIDAFTARKAN SEMUA DI SINI)
    routes: [
      // Halaman Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Halaman Utama Mahasiswa (Materi, Forum, dll)
      GoRoute(
        path: '/student',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      // HALAMAN UTAMA DOSEN (Ini yang tadi hilang sehingga error 404)
      GoRoute(
        path: '/lecturer',
        builder: (context, state) => const LecturerDashboardScreen(),
      ),
    ],
  );
});