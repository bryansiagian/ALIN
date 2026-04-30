import 'package:flutter_math/models/user_model.dart';

class LeaderboardModel {
  final int id;
  final int userId;
  final int totalPoints;
  final int? rank;
  final String period; // weekly, monthly, all_time
  final UserModel? user; // Untuk menampilkan nama & avatar di list

  LeaderboardModel({
    required this.id,
    required this.userId,
    required this.totalPoints,
    this.rank,
    required this.period,
    this.user,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) => LeaderboardModel(
    id: json['id'],
    userId: json['user_id'],
    totalPoints: json['total_points'],
    rank: json['rank'],
    period: json['period'],
    user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
  );
}