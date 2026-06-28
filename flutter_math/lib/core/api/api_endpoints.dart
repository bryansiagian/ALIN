class ApiEndpoints {
  //static const String baseUrl = 'https://9ide6w2asa.ap-southeast-2.awsapprunner.com/api/'; // Emulator IP
  static const String baseUrl ='http://13.211.72.60/api/'; // Emulator IP


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

  // Placement
  static const String placement        = 'placement';          // GET  - ambil soal
  static const String placementSubmit  = 'placement/submit';   // POST - submit jawaban
  static const String placementResult  = 'placement/result';   // GET  - ambil hasil

  // Set placement assignment (untuk dosen, di dalam group middleware 'lecturer')
  // Endpoint: POST /api/lecturer/assignments/{id}/set-placement
  // Tidak perlu konstanta string di sini karena pakai dynamic segment:
  //   final url = 'lecturer/assignments/$assignmentId/set-placement';

  static String levelQuestions(int level) => 'levels/$level/questions'; 
  static const String levelSubmit = 'levels/submit';
}