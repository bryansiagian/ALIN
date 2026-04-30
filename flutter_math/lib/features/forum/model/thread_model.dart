import 'package:flutter_math/models/user_model.dart';

class ThreadModel {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final int viewsCount;
  final DateTime createdAt;
  final UserModel user;
  final String topicTitle;

  ThreadModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.viewsCount,
    required this.createdAt,
    required this.user,
    required this.topicTitle,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    imageUrl: json['image_url'],
    viewsCount: json['views_count'] ?? 0,
    createdAt: DateTime.parse(json['created_at']),
    user: UserModel.fromJson(json['user']),
    topicTitle: json['topic'] != null ? json['topic']['title'] : 'Umum',
  );
}