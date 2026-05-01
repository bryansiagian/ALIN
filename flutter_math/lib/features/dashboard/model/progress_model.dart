class UserAnalyticsModel {
  final int currentStreak;
  final int overallPercentage;
  final int completedTopics;
  final List<dynamic> sessions; // TAMBAHKAN INI

  UserAnalyticsModel({
    required this.currentStreak,
    required this.overallPercentage,
    required this.completedTopics,
    required this.sessions, // TAMBAHKAN INI
  });

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final sessionList = json['sessions'] as List? ?? [];
    
    // TAMBAHKAN BARIS INI UNTUK DEBUG DI TERMINAL:
    print("DEBUG: Jumlah sesi yang diterima dari Laravel: ${sessionList.length}");

    return UserAnalyticsModel(
      currentStreak: json['streak'] != null ? json['streak']['current_streak'] : 0,
      overallPercentage: json['overall_percentage'] ?? 0,
      completedTopics: json['completed_topics'] ?? 0,
      sessions: sessionList,
    );
  }
}