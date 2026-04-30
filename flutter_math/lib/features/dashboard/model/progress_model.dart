class TopicAnalyticsModel {
  final int topicId;
  final String topicTitle;
  final int scoreAvg;
  final int timeSpentSeconds;
  final String status;

  TopicAnalyticsModel({
    required this.topicId,
    required this.topicTitle,
    required this.scoreAvg,
    required this.timeSpentSeconds,
    required this.status,
  });

  factory TopicAnalyticsModel.fromJson(Map<String, dynamic> json) => TopicAnalyticsModel(
    topicId: json['topic_id'],
    topicTitle: json['topic']['title'],
    scoreAvg: json['score_avg'] ?? 0,
    timeSpentSeconds: json['time_spent_seconds'] ?? 0,
    status: json['status'],
  );
}

class UserAnalyticsModel {
  final int currentStreak;
  final int overallPercentage;
  final int completedTopics;
  final List<TopicAnalyticsModel> topicAnalytics;

  UserAnalyticsModel({
    required this.currentStreak,
    required this.overallPercentage,
    required this.completedTopics,
    required this.topicAnalytics,
  });

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsModel(
      currentStreak: json['streak'] != null ? json['streak']['current_streak'] : 0,
      overallPercentage: json['overall_percentage'] ?? 0,
      completedTopics: json['completed_topics'] ?? 0,
      topicAnalytics: (json['topic_analytics'] as List)
          .map((e) => TopicAnalyticsModel.fromJson(e))
          .toList(),
    );
  }
}