class AssignmentModel {
  final int id;
  final int lecturerId;
  final int topicId;
  final String title;
  final String? description;
  final DateTime? startTime; // ✅ TAMBAH
  final DateTime deadline;
  final int durationMinutes;
  final int questionCount;
  final bool isSafeExam;
  final String status;
  final bool allowReattempt;
  final int attemptLimit;
  final bool showResults;
  final int examSessionsCount;
  final bool isPlacement;

  AssignmentModel({
    required this.id,
    required this.lecturerId,
    required this.topicId,
    required this.title,
    this.description,
    this.startTime, // ✅ TAMBAH
    required this.deadline,
    required this.durationMinutes,
    required this.questionCount,
    required this.isSafeExam,
    required this.status,
    required this.allowReattempt,
    required this.attemptLimit,
    required this.showResults,
    required this.examSessionsCount,
    required this.isPlacement,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      lecturerId: json['lecturer_id'],
      topicId: json['topic_id'],
      title: json['title'],
      description: json['description'],
      startTime:
          json['start_time'] !=
              null // ✅ TAMBAH
          ? DateTime.parse(json['start_time'])
          : null,
      deadline: DateTime.parse(json['deadline']),
      durationMinutes: json['duration_minutes'],
      questionCount: json['question_count'],
      isSafeExam: json['is_safe_exam'] == 1 || json['is_safe_exam'] == true,
      status: json['status'],
      allowReattempt:
          json['allow_reattempt'] == 1 || json['allow_reattempt'] == true,
      attemptLimit: json['attempt_limit'] ?? 1,
      showResults: json['show_results'] == 1 || json['show_results'] == true,
      examSessionsCount: json['exam_sessions_count'] ?? 0,
      isPlacement: json['is_placement'] == 1 || json['is_placement'] == true,
    );
  }
}
