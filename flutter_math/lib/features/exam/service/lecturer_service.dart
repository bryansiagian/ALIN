import 'package:dio/dio.dart';
import 'package:flutter_math/models/assignment_model.dart'; // Pastikan model sudah ada
import 'package:flutter_math/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';

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

  Future<void> createNewQuestion(Map<String, dynamic> data) async {
    await _dio.post('lecturer/questions', data: data);
  }

  Future<List<UserModel>> getAllStudents() async {
    final response = await _dio.get('lecturer/students');
    return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getStudentDetail(int id) async {
    final response = await _dio.get('lecturer/students/$id');
    return response.data;
  }

  Future<void> updateQuestion(int id, Map<String, dynamic> data) async {
    await _dio.put('lecturer/questions/$id', data: data);
  }

  // --- BARU: Method untuk Reset Percobaan Mahasiswa ---
  Future<void> resetAttempt(int sessionId) async {
    await _dio.delete('lecturer/sessions/$sessionId/reset');
  }
}

final myAssignmentsProvider = FutureProvider<List<AssignmentModel>>((ref) async {
  final service = LecturerService(ref.watch(apiClientProvider).dio);
  return service.getMyAssignments();
});

final lecturerServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return LecturerService(dio);
});