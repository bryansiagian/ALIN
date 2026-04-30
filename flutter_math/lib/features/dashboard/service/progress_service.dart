import 'package:dio/dio.dart';
import 'package:flutter_math/features/dashboard/model/progress_model.dart';

class ProgressService {
  final Dio _dio;
  ProgressService(this._dio);

  Future<UserAnalyticsModel> getAnalytics() async {
    final response = await _dio.get('analytics');
    return UserAnalyticsModel.fromJson(response.data);
  }
}