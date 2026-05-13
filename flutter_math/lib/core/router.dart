import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/auth/screen/login_screen.dart';
import 'package:flutter_math/features/dashboard/screen/main_navigation_screen.dart';
import 'package:flutter_math/features/exam/screen/main_lecturer_screen.dart';
import 'package:flutter_math/features/placement/screen/placement_screen.dart';

/// Adapter: mengubah Riverpod StateNotifier menjadi Listenable
/// agar GoRouter bisa mendengar perubahan authState secara reaktif.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    // Mulai dengarkan perubahan authProvider
    _ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners(); // Beritahu GoRouter untuk re-evaluate redirect
    });
  }

  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation: '/',
    // refreshListenable = kunci utama agar GoRouter reaktif terhadap login/logout
    refreshListenable: listenable,
    redirect: (context, state) {
      // Baca authState langsung dari ref (bukan watch) agar selalu fresh
      final authState = ref.read(authProvider);

      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isOnPlacement = state.matchedLocation == '/placement';

      // 1. Belum login → paksa ke /login
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      // 2. Sudah login, mahasiswa, belum placement → paksa ke /placement
      if (authState.user!.role == 'student' &&
          !authState.user!.hasTakenPlacement) {
        return isOnPlacement ? null : '/placement';
      }

      // 3. Sudah login + placement selesai (atau dosen) →
      //    redirect dari /login atau / ke halaman utama
      if (isLoggingIn || state.matchedLocation == '/') {
        return switch (authState.user!.role) {
          'lecturer' => '/lecturer',
          'admin'    => '/lecturer', // sesuaikan jika ada halaman admin
          _          => '/student',
        };
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/placement',
        builder: (context, state) => const PlacementScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/lecturer',
        builder: (context, state) => const MainLecturerScreen(),
      ),
    ],
  );
});