import 'package:dio/dio.dart';
import 'package:flutter_math/models/assignment_model.dart'; // Pastikan model sudah ada

class LecturerService {
  final Dio _dio;
  LecturerService(this._dio);

  Future<List<AssignmentModel>> getMyAssignments() async {
    final response = await _dio.get('lecturer/assignments');
    return (response.data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<void> createAssignment(Map<String, dynamic> data) async {
    await _dio.post('lecturer/assignments', data: data);
  }

  Future<List<dynamic>> getAssignmentResults(int id) async {
    final response = await _dio.get('lecturer/assignments/$id/results');
    return response.data;
  }

  Future<List<dynamic>> getAssignmentQuestions(int id) async {
    final response = await _dio.get('lecturer/assignments/$id/questions');
    return response.data;
  }
}