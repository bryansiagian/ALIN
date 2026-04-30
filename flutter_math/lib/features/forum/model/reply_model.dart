import 'package:flutter_math/models/user_model.dart';

class ReplyModel {
  final int id;
  final String body;
  final int? parentReplyId;
  final DateTime createdAt;
  final UserModel user;
  final List<ReplyModel> children; // Untuk nested replies

  ReplyModel({
    required this.id,
    required this.body,
    this.parentReplyId,
    required this.createdAt,
    required this.user,
    this.children = const [],
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    var list = json['children'] as List? ?? [];
    List<ReplyModel> childList = list.map((i) => ReplyModel.fromJson(i)).toList();

    return ReplyModel(
      id: json['id'],
      body: json['body'],
      parentReplyId: json['parent_reply_id'],
      createdAt: DateTime.parse(json['created_at']),
      user: UserModel.fromJson(json['user']),
      children: childList,
    );
  }
} 