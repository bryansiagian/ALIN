import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';

class LevelRepository {
  final ApiClient _apiClient;

  LevelRepository(this._apiClient);

  /// 1. Mengambil 5 soal acak dari Laravel berdasarkan nomor level (1 - 1000)
  Future<Map<String, dynamic>> getQuestionsByLevel(int level) async {
    try {
      // Menggunakan objek dio bawaan ApiClient Anda, token otomatis terinjeksi!
      final response = await _apiClient.dio.get(
        ApiEndpoints.levelQuestions(level),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal memuat soal level $level: $e');
    }
  }

  /// 2. Mengirimkan daftar jawaban kuis level mahasiswa ke Laravel
  Future<Map<String, dynamic>> submitLevelResult({
    required int level,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.levelSubmit,
        data: {'level': level, 'answers': answers},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal mengirimkan hasil evaluasi level: $e');
    }
  }
}

/// --- REGISTRASI PROVIDER AGAR BISA DI-WATCH OLEH WIDGET FLUTTER ---
final levelRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LevelRepository(apiClient);
});
