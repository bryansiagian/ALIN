class AssignmentModel {
  final int id;
  final int lecturerId;
  final int topicId;
  final String title;
  final String? description;
  final DateTime deadline;
  final int durationMinutes;
  final int questionCount;
  final bool isSafeExam;
  final String status;
  final String? topicTitle; // Tambahan jika API melakukan join dengan tabel topics

  AssignmentModel({
    required this.id,
    required this.lecturerId,
    required this.topicId,
    required this.title,
    this.description,
    required this.deadline,
    required this.durationMinutes,
    required this.questionCount,
    required this.isSafeExam,
    required this.status,
    this.topicTitle,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      lecturerId: json['lecturer_id'],
      topicId: json['topic_id'],
      title: json['title'],
      description: json['description'],
      // Konversi string timestamp dari Laravel ke DateTime Dart
      deadline: DateTime.parse(json['deadline']),
      durationMinutes: json['duration_minutes'],
      questionCount: json['question_count'],
      // Laravel mengirim boolean sebagai 1/0 atau true/false
      isSafeExam: json['is_safe_exam'] == 1 || json['is_safe_exam'] == true,
      status: json['status'],
      // Mengambil title dari relasi topic jika ada (Eager Loading di Laravel)
      topicTitle: json['topic'] != null ? json['topic']['title'] : null,
    );
  }

  /// Helper untuk mengecek apakah tugas masih bisa dikerjakan
  bool get isExpired => DateTime.now().isAfter(deadline);

  /// Helper untuk memformat durasi menjadi teks
  String get durationText => "$durationMinutes Menit";
}