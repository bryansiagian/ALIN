import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/features/gamification/model/leaderboard_model.dart';
import 'package:flutter_math/features/gamification/model/badge_model.dart';

class GamificationService {
  final Dio _dio;
  GamificationService(this._dio);

  Future<List<LeaderboardModel>> getLeaderboard() async {
    final response = await _dio.get(ApiEndpoints.leaderboard);
    return (response.data as List).map((e) => LeaderboardModel.fromJson(e)).toList();
  }

  Future<List<BadgeModel>> getMyBadges() async {
    final response = await _dio.get('badges'); // Sesuai endpoint di api.php
    return (response.data as List).map((e) => BadgeModel.fromJson(e)).toList();
  }
}