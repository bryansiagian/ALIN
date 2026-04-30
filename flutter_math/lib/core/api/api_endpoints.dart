class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:8000/api/'; // Emulator IP

  // Auth
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String me = 'me';

  // Learning
  static const String topics = 'content/topics';
  static String materials(int topicId) => 'content/topics/$topicId/materials';
  static const String formulas = 'content/formulas';

  // Exam (SEB)
  static const String assignments = 'exam/assignments';
  static String startExam(int id) => 'exam/assignments/$id/start';
  static String reportViolation(int sessionId) => 'exam/sessions/$sessionId/violation';
  static String submitExam(int sessionId) => 'exam/sessions/$sessionId/submit';

  // Others
  static const String leaderboard = 'leaderboard';
  static const String threads = 'forum/threads';
}