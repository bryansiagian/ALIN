import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';

class ContentService {
  final Dio _dio;

  ContentService(this._dio);

  // Fungsi pemanggil API untuk Peta Harta Karun (Leveling)
  Future<List<dynamic>> fetchTopics() async {
    try {
      // Lihat! Sangat pendek karena token sudah diurus oleh auth_interceptor
      final response = await _dio.get(ApiEndpoints.topics);

      // Mengembalikan daftar topik dari laci mesin belakang (Laravel)
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat peta harta karun';
    }
  }
}


final contentServiceProvider = Provider((ref) {
  // Mengambil mobil kurir (Dio) dari apiClientProvider milikmu
  final apiClient = ref.watch(apiClientProvider);
  return ContentService(apiClient.dio);
});

// Pipa 2: Menyediakan aliran air (data materi) secara otomatis
final topicsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.watch(contentServiceProvider);
  return await service.fetchTopics();
});
