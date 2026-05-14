import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      return {
        'token': response.data['token'],
        'user': UserModel.fromJson(response.data['user']),
      };
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message ?? e.type.toString();
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return {
        'token': response.data['token'],
        'user': UserModel.fromJson(response.data['user']),
      };
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal registrasi';
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }
}