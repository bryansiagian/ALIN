import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/dashboard/service/progress_service.dart';
import 'package:flutter_math/features/dashboard/model/progress_model.dart';

final progressServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ProgressService(dio);
});

final analyticsProvider = FutureProvider<UserAnalyticsModel>((ref) async {
  return ref.watch(progressServiceProvider).getAnalytics();
});