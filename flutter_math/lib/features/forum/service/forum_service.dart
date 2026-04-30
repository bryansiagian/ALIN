import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_math/core/api/api_endpoints.dart';
import 'package:flutter_math/features/forum/model/thread_model.dart';
import 'package:flutter_math/features/forum/model/reply_model.dart';

class ForumService {
  final Dio _dio;
  ForumService(this._dio);

  Future<List<ThreadModel>> getThreads() async {
    final response = await _dio.get(ApiEndpoints.threads);
    return (response.data as List).map((e) => ThreadModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getThreadDetail(int id) async {
    final response = await _dio.get('${ApiEndpoints.threads}/$id');
    return response.data; // Mengembalikan {thread: ..., replies: [...]}
  }

  Future<void> createThread({
    required String title,
    required String body,
    required int topicId,
    File? image,
  }) async {
    FormData formData = FormData.fromMap({
      'title': title,
      'body': body,
      'topic_id': topicId,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path, filename: 'forum_post.jpg'),
    });

    await _dio.post(ApiEndpoints.threads, data: formData);
  }

  Future<void> postReply(int threadId, String body, {int? parentReplyId}) async {
    await _dio.post('${ApiEndpoints.threads}/$threadId/replies', data: {
      'body': body,
      'parent_reply_id': parentReplyId,
    });
  }
}