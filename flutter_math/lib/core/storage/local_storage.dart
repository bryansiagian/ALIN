import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async => await _storage.write(key: 'auth_token', value: token);
  Future<String?> getToken() async => await _storage.read(key: 'auth_token');
  Future<void> deleteToken() async => await _storage.delete(key: 'auth_token');
}

// DEFINISIKAN DI SINI
final localStorageProvider = Provider((ref) => LocalStorage());