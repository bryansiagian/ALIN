import 'package:flutter_math/models/user_model.dart';

class ThreadModel {
  final int id;
  final String title;
  final String body;
  final String topicTitle;
  final DateTime createdAt;
  final UserModel user;
  final int repliesCount;

  ThreadModel({
    required this.id,
    required this.title,
    required this.body,
    required this.topicTitle,
    required this.createdAt,
    required this.user,
    required this.repliesCount,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: json['id'],
    title: json['title']?.toString() ?? "Tanpa Judul", // Handle null
    body: json['body']?.toString() ?? "",              // Handle null
    topicTitle: json['topic'] != null ? json['topic']['title'].toString() : "Umum",
    createdAt: DateTime.parse(json['created_at']),
    user: UserModel.fromJson(json['user']),
    repliesCount: json['replies_count'] ?? 0,
  );
}