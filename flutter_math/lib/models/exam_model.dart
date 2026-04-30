class AssignmentModel {
  final int id;
  final String title;
  final DateTime endTime;
  final int durationMinutes;
  final bool isSafeExam;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.endTime,
    required this.durationMinutes,
    required this.isSafeExam,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      title: json['title'],
      endTime: DateTime.parse(json['end_time']),
      durationMinutes: json['duration_minutes'],
      isSafeExam: json['is_safe_exam'] == 1 || json['is_safe_exam'] == true,
    );
  }
}