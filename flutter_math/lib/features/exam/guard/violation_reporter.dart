import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';

class ViolationReporter {
  final Dio _dio;

  ViolationReporter(this._dio);

  /// Melaporkan pelanggaran ke backend.
  /// Melempar [String] pesan error jika gagal.
  Future<Map<String, dynamic>> report(int sessionId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reportViolation(sessionId),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      throw (msg is String) ? msg : 'Gagal melaporkan pelanggaran';
    }
  }
}