import 'package:dio/dio.dart';
import 'package:flutter_math/core/api_client.dart';
import 'package:flutter_math/models/exam_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamService {
  final Dio _dio;

  ExamService(this._dio);

  // Ambil daftar tugas/ujian
  Future<List<AssignmentModel>> getAssignments() async {
    final response = await _dio.get('exam/assignments');
    return (response.data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  // Lapor Pelanggaran (Fitur SEB)
  Future<void> reportViolation(int sessionId) async {
    try {
      await _dio.post('exam/sessions/$sessionId/violation');
    } catch (e) {
      print("Gagal melapor pelanggaran: $e");
    }
  }
}

final examServiceProvider = Provider((ref) => ExamService(ref.read(dioProvider)));