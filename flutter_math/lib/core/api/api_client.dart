import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Wajib untuk IOHttpClientAdapter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/core/api/interceptors/auth_interceptor.dart';
import 'package:flutter_math/core/storage/local_storage.dart';

class ApiClient {
  late Dio dio;

  ApiClient(LocalStorage storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        // Kita hapus Content-Type dari sini agar bisa di-handle dinamis oleh Dio
        // (terutama jika Anda nantinya menggunakan FormData)
        headers: {'Accept': 'application/json'},
      ),
    );

    // Menggunakan Adapter agar koneksi ke IP lokal lebih stabil di Android
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Membuka celah sertifikat jika Laravel menggunakan HTTPS lokal/self-signed
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    // Aktifkan kembali setelah Anda yakin koneksi sudah tembus
    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }
}

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiClient(storage);
});
