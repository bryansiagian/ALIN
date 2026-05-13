import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';

class PlacementService {
  final Dio _dio;

  PlacementService(this._dio);

  /// Ambil soal placement test.
  /// Throws jika sudah pernah dikerjakan (403) atau belum ada placement (404).
  Future<List<Map<String, dynamic>>> getQuestions() async {
    try {
      final response = await _dio.get(ApiEndpoints.placement);
      final data = response.data;

      // Backend mengembalikan { assignment: {...}, questions: [...] }
      final raw = data['questions'] as List? ?? data as List;
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat soal placement';
    }
  }

  /// Submit jawaban placement test.
  /// [answers] adalah Map<questionId, selectedLabel> misal {1: 'A', 2: 'C', ...}
  /// Mengembalikan { score: double, grade: String }
  Future<Map<String, dynamic>> submitAnswers(Map<int, String> answers) async {
    try {
      // Format sesuai yang diterima backend PlacementController@submit
      final formatted = answers.map(
        (id, label) => MapEntry(id.toString(), label),
      );

      final response = await _dio.post(
        ApiEndpoints.placementSubmit,
        data: {'answers': formatted},
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal submit placement test';
    }
  }

  /// Ambil hasil placement (untuk ditampilkan di profil atau saat re-check).
  Future<Map<String, dynamic>> getResult() async {
    try {
      final response = await _dio.get(ApiEndpoints.placementResult);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat hasil placement';
    }
  }
}