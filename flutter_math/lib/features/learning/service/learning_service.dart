import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/features/learning/model/topic_model.dart';
import 'package:flutter_math/features/learning/model/material_model.dart';
import 'package:flutter_math/features/learning/model/formula_model.dart';

class LearningService {
  final Dio _dio;
  LearningService(this._dio);

  Future<List<TopicModel>> getTopics() async {
    final response = await _dio.get(ApiEndpoints.topics);
    return (response.data as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<List<MaterialModel>> getMaterials(int topicId) async {
    final response = await _dio.get(ApiEndpoints.materials(topicId));
    // Mengambil data dari key 'materials' sesuai struktur response Laravel
    return (response.data['materials'] as List).map((e) => MaterialModel.fromJson(e)).toList();
  }

  Future<List<FormulaModel>> getFormulas() async {
    final response = await _dio.get(ApiEndpoints.formulas);
    return (response.data as List).map((e) => FormulaModel.fromJson(e)).toList();
  }

  Future<List<dynamic>> fetchTopics() async {
    try {
      final response = await _dio.get(ApiEndpoints.topics);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat peta harta karun';
    }
  }
}