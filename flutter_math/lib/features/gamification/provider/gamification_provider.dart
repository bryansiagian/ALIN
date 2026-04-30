import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/gamification/service/gamification_service.dart';
import 'package:flutter_math/features/gamification/model/leaderboard_model.dart';
import 'package:flutter_math/features/gamification/model/badge_model.dart';

final gamificationServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return GamificationService(dio);
});

final leaderboardProvider = FutureProvider<List<LeaderboardModel>>((ref) async {
  return ref.watch(gamificationServiceProvider).getLeaderboard();
});

final badgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  return ref.watch(gamificationServiceProvider).getMyBadges();
});