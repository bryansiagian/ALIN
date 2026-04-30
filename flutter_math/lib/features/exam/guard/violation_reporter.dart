import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';

class ViolationReporter {
  final Dio _dio;
  ViolationReporter(this._dio);

  Future<Map<String, dynamic>> report(int sessionId) async {
    try {
      // Pastikan ApiEndpoints.reportViolation mengarah ke endpoint Laravel yang benar
      final response = await _dio.post(ApiEndpoints.reportViolation(sessionId));
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal lapor';
    }
  }
}