import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/core/api/interceptors/auth_interceptor.dart';
import 'package:flutter_math/core/storage/local_storage.dart';

class ApiClient {
  late Dio dio;

  ApiClient(LocalStorage storage) {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}

// DEFINISIKAN DI SINI AGAR BISA DIPAKAI DASHBOARD, EXAM, DLL
final apiClientProvider = Provider((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiClient(storage);
});