import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/forum/model/thread_model.dart';

class ForumService {
  final Dio _dio;
  ForumService(this._dio);

  Future<List<ThreadModel>> getThreads() async {
    final response = await _dio.get('forum/threads');
    return (response.data as List).map((e) => ThreadModel.fromJson(e)).toList();
  } 

  Future<Map<String, dynamic>> getThreadDetail(int id) async {
    final response = await _dio.get('forum/threads/$id');
    return response.data;
  }

  Future<void> postReply(int threadId, String body) async {
    await _dio.post('forum/threads/$threadId/replies', data: {'body': body});
  }

  Future<void> postThread({required String body, String? title}) async {
    await _dio.post('forum/threads', data: {
      'title': title ?? "Diskusi Baru",
      'body': body, // <--- Kunci ini harus sama dengan di Controller Laravel
      'topic_id': 1,
    });
  }
}

final forumServiceProvider = Provider((ref) => ForumService(ref.watch(apiClientProvider).dio));

final threadsProvider = FutureProvider<List<ThreadModel>>((ref) async {
  return ref.watch(forumServiceProvider).getThreads();
});