import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/models/assignment_model.dart';

class ExamService {
  final Dio _dio;
  ExamService(this._dio);

  // 1. Ambil daftar kuis untuk mahasiswa
  Future<List<AssignmentModel>> getAssignments() async {
    final response = await _dio.get(ApiEndpoints.assignments);
    return (response.data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  // 2. MULAI UJIAN (Ambil Session ID dan Soal)
  Future<Map<String, dynamic>> startExam(int id) async {
    try {
      final response = await _dio.post(ApiEndpoints.startExam(id));
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memulai ujian';
    }
  }

  // 3. SUBMIT UJIAN (Kirim Skor Akhir)
  Future<void> submitExam({
    required int sessionId,
    required int score,
    required Map<String, String> answers,
  }) async {
    try {
      await _dio.post(ApiEndpoints.submitExam(sessionId), data: {
        'total_score': score, // Sesuai DBML Laravel
        'answers': answers,   // Detail jawaban per soal
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengirim ujian';
    }
  }

  Future<void> reportViolation(int sessionId) async {
    await _dio.post(ApiEndpoints.reportViolation(sessionId));
  }
}

// Global Provider
final examServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ExamService(dio);
});