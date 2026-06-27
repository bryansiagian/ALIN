import 'package:dio/dio.dart';
import 'package:flutter_math/models/assignment_model.dart';
import 'package:flutter_math/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'dart:io';

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

  Future<String> uploadQuestionImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });
    final response = await _dio.post('/lecturer/upload-image', data: formData);
    return response.data['url'] as String;
  }

  Future<void> resetAttempt(int sessionId) async {
    await _dio.delete('lecturer/sessions/$sessionId/reset');
  }

  Future<void> createTopic({required String title, String? description}) async {
    await _dio.post('lecturer/topics', data: {
      'title': title,
      'description': description,
    });
  }

  Future<List<dynamic>> getTopicsList() async {
    final response = await _dio.get('lecturer/topics-list');
    return response.data;
  }

  Future<void> uploadMaterial({
    required int topicId,
    required String title,
    required String filePath,
  }) async {
    FormData formData = FormData.fromMap({
      'topic_id': topicId,
      'title': title,
      'pdf_file': await MultipartFile.fromFile(filePath, filename: 'materi.pdf'),
    });
    await _dio.post('lecturer/materials', data: formData);
  }

  // ← BARU: Jadikan assignment sebagai placement test
  Future<void> setPlacementAssignment(int assignmentId) async {
    await _dio.post('lecturer/assignments/$assignmentId/set-placement');
  }

  Future<List<dynamic>> getPlacementResults() async {
    final response = await _dio.get('lecturer/placement/results');
    return response.data;
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