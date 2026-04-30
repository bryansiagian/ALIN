import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/forum/service/forum_service.dart';
import 'package:flutter_math/features/forum/model/thread_model.dart';

final forumServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ForumService(dio);
});

final threadsProvider = FutureProvider<List<ThreadModel>>((ref) async {
  return ref.watch(forumServiceProvider).getThreads();
});

// Provider detail menggunakan .family untuk menerima ID thread
final threadDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  return ref.watch(forumServiceProvider).getThreadDetail(id);
});