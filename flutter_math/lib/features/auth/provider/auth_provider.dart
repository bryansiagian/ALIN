import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/models/user_model.dart';
import 'package:flutter_math/features/auth/service/auth_service.dart';
import 'package:flutter_math/core/storage/local_storage.dart';
import 'package:flutter_math/core/api/api_client.dart';

// --- State Class ---
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  // Helper untuk mengcopy state (immutability)
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// --- Notifier Class ---
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final LocalStorage _storage;

  AuthNotifier(this._authService, this._storage) : super(AuthState());

  /// Cek apakah ada token di storage dan ambil data user (Auto Login)
  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    if (token == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      // Jika token expired atau error, hapus token
      await _storage.deleteToken();
      state = AuthState(user: null, isLoading: false);
    }
  }

  /// Proses Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(email, password);
      
      // Simpan token ke Secure Storage
      await _storage.saveToken(result['token']);
      
      // Update State dengan data user
      state = state.copyWith(
        user: result['user'] as UserModel,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.toString()
      );
    }
  }

  /// Proses Registrasi
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      await _storage.saveToken(result['token']);
      state = state.copyWith(
        user: result['user'] as UserModel,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Proses Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
    } catch (e) {
      // Tetap lanjutkan hapus token lokal meski API logout gagal
    } finally {
      await _storage.deleteToken();
      state = AuthState(user: null, isLoading: false);
    }
  }
}

// --- Providers ---

// Provider untuk AuthService
final authServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return AuthService(dio);
});

// Global Provider untuk AuthState
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storage = ref.watch(localStorageProvider);
  return AuthNotifier(authService, storage);
});