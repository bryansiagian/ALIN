import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';
import 'package:flutter_math/features/exam/screen/exam_result_screen.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/placement/provider/placement_provider.dart';
import 'package:flutter_math/core/api/api_client.dart'; // Mengamankan gerbang komunikasi Dio
import 'package:dio/dio.dart';

import 'progress_screen_visual.dart';
import 'progress_screen_helpers.dart';

// ── SUNTIKKAN PROVIDER MANDIRI DI SINI (SOLUSI JELAS GAIB KUIS BARU) ──
final studentAssignmentsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.dio.get('/exam/assignments');
  return response.data as List<dynamic>;
});
// ───────────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF1A5FD4).withOpacity(0.9),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F2D6B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFFE5E7EB),
    );
  }
}

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    // Ikut pantau daftar kuis aktif langsung dari server
    final assignmentsAsync = ref.watch(studentAssignmentsProvider);

    final user = ref.watch(authProvider).user;
    final hasTakenPlacement = user?.hasTakenPlacement ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1A5FD4),
            expandedHeight: 130,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    ref.invalidate(analyticsProvider);
                    ref.invalidate(studentAssignmentsProvider);
                    if (hasTakenPlacement) {
                      ref.invalidate(placementResultProvider);
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  tooltip: "Refresh",
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A40A8),
                      Color(0xFF2D6EE8),
                      Color(0xFF4B8EFF),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Riwayat Aktivitas",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Pantau perkembangan belajarmu",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Placement Result Section ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PlacementSection(hasTakenPlacement: hasTakenPlacement),
            ),
          ),

          // ── Kuis Reguler Content ─────────────────────────────────────
          analyticsAsync.when(
            data: (analyticsData) {
              final sessions = analyticsData.sessions;

              return assignmentsAsync.when(
                data: (assignments) {
                  if (assignments.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: const SliverFillRemaining(
                        child: _EmptyQuizState(),
                      ),
                    );
                  }

                  // Hitung skor rata-rata berdasarkan sesi yang sudah disubmit
                  final submittedSessions = sessions
                      .where((s) => s['status'] == 'submitted')
                      .toList();
                  final scores = submittedSessions
                      .map<num>((s) => s['total_score'] ?? 0)
                      .toList();
                  final avg = scores.isEmpty
                      ? 0.0
                      : scores.reduce((a, b) => a + b) / scores.length;
                  final best = scores.isEmpty
                      ? 0.0
                      : scores.reduce((a, b) => a > b ? a : b);

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0) {
                          return _SummaryCard(
                            total: submittedSessions.length,
                            avg: avg.toDouble(),
                            best: best.toDouble(),
                          );
                        }
                        if (index == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF4B8EFF),
                                        Color(0xFF1A5FD4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Daftar Ujian & Kuis Aktif",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F2D6B),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${assignments.length} kuis",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final idx = index - 2;
                        final assignment = assignments[idx];
                        final int assignmentId = assignment['id'] ?? 0;

                        // Cari apakah ada riwayat pengerjaan mahasiswa untuk kuis ini
                        final matchingSessions = sessions
                            .where((s) => s['assignment_id'] == assignmentId)
                            .toList();
                        final dynamic latestSession =
                            matchingSessions.isNotEmpty
                            ? matchingSessions.first
                            : null;

                        final int totalAttempts =
                            assignment['exam_sessions_count'] ??
                            matchingSessions.length;

                        return _SessionCard(
                          session:
                              latestSession, // Bisa bernilai null jika kuis baru belum disentuh
                          assignment: assignment,
                          attempt: totalAttempts,
                          onTap: () => _handleAssignmentAccessGate(
                            context,
                            ref,
                            latestSession,
                            assignment,
                            sessions,
                          ),
                        );
                      }, childCount: assignments.length + 2),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D6EE8)),
                  ),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: _ErrorState(message: err.toString()),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2D6EE8),
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: _ErrorState(message: err.toString()),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAssignmentAccessGate(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
    dynamic assignment,
    List<dynamic> allSessions,
  ) {
    final int assignmentId = assignment['id'] ?? 0;
    final bool allowReattempt = assignment['allow_reattempt'] ?? false;
    final int attemptLimit = assignment['attempt_limit'] ?? 1;

    final int totalCompletedAttempts = allSessions
        .where((s) => s['assignment_id'] == assignmentId)
        .length;

    // 1. Validasi gembok waktu mulai kuis (Menampilkan waktu mulai & deadline secara rapi)
    final String? startTimeStr = assignment['start_time'];
    final String? deadlineStr =
        assignment['deadline']; // Ambil data deadline dari koper kuis

    if (startTimeStr != null) {
      final DateTime startTime = DateTime.parse(startTimeStr);
      if (DateTime.now().isBefore(startTime)) {
        // Konversi kedua string waktu menjadi format yang mudah dibaca mata mahasiswa
        final String startFormatted = _formatHumanReadableDateTime(
          startTimeStr,
        );
        final String deadlineFormatted = _formatHumanReadableDateTime(
          deadlineStr,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange[800],
            duration: const Duration(seconds: 4),
            content: Row(
              children: [
                const Icon(Icons.watch_later_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Akses ditolak: Kuis ini hanya dapat diakses mulai $startFormatted hingga $deadlineFormatted.",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }
    }

    // 2. Jika sesi belum pernah dibuat (Kuis baru 0 Sesi) -> Tantang password langsung
    if (session == null) {
      _challengeQuizPassword(context, ref, assignmentId, assignment);
      return;
    }

    // 3. Manajemen penempuhan ulang kuis adaptif
    if (allowReattempt && totalCompletedAttempts < attemptLimit) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF1A5FD4),
                    ),
                    title: const Text(
                      "Lihat Detail Hasil Sesi Ini",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _viewDetail(context, session, assignment);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.replay_rounded,
                      color: Colors.green,
                    ),
                    title: Text(
                      "Mulai Percobaan Baru (${totalCompletedAttempts + 1}/$attemptLimit)",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _challengeQuizPassword(
                        context,
                        ref,
                        assignmentId,
                        assignment,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      _viewDetail(context, session, assignment);
    }
  }

  void _challengeQuizPassword(
    BuildContext context,
    WidgetRef ref,
    int assignmentId,
    dynamic assignment,
  ) {
    final String? quizPassword = assignment['password'];

    if (quizPassword != null && quizPassword.isNotEmpty) {
      final passwordController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.redAccent),
                SizedBox(width: 10),
                Text(
                  "Password Diperlukan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kuis ini terkunci. Silakan masukkan password valid dari dosen pengampu.",
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password Kuis",
                    prefixIcon: const Icon(
                      Icons.vpn_key_rounded,
                      size: 18,
                      color: Color(0xFF1A5FD4),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5FD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final String enteredText = passwordController.text.trim();
                  Navigator.pop(context);
                  _executeStartExamNetworkCall(
                    context,
                    ref,
                    assignmentId,
                    enteredText,
                  );
                },
                child: const Text(
                  "Masuk Ujian",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } else {
      _executeStartExamNetworkCall(context, ref, assignmentId, null);
    }
  }

  void _executeStartExamNetworkCall(
    BuildContext context,
    WidgetRef ref,
    int assignmentId,
    String? password,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A5FD4)),
      ),
    );

    try {
      final apiClient = ref.read(apiClientProvider);

      final response = await apiClient.dio.post(
        '/exam/assignments/$assignmentId/start',
        data: password != null ? {'password': password} : null,
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              "Sukses: Lembar kuis adaptif berhasil diamankan dari server!",
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      String errorMessage = "Gagal terhubung ke ruang ujian.";
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE53935),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(errorMessage)),
            ],
          ),
        ),
      );
    }
  }

  void _viewDetail(BuildContext context, dynamic session, dynamic assignment) {
    Map<int, String> userAnswers = {};
    final List answers = session['answers'] ?? [];
    for (var a in answers) {
      userAnswers[a['question_id']] = a['user_answer'];
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          score: session['total_score'] ?? 0,
          questions: assignment['questions'] ?? [],
          userAnswers: userAnswers,
          canShowDetail: true,
        ),
      ),
    );
  }

    String _formatHumanReadableDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateTimeStr);
      final String day = dt.day.toString().padLeft(2, '0');
      final String month = dt.month.toString().padLeft(2, '0');
      final String year = dt.year.toString();
      final String hour = dt.hour.toString().padLeft(2, '0');
      final String minute = dt.minute.toString().padLeft(2, '0');

      return '$day-$month-$year pukul $hour:$minute';
    } catch (_) {
      return dateTimeStr ?? '-';
    }
  }
}

class _PlacementSection extends ConsumerWidget {
  final bool hasTakenPlacement;
  const _PlacementSection({required this.hasTakenPlacement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Placement Test",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F2D6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (!hasTakenPlacement)
          _PlacementNotTakenCard()
        else
          const _PlacementResultCard(),
      ],
    );
  }
}

class _PlacementNotTakenCard extends StatelessWidget {
  const _PlacementNotTakenCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E0FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.quiz_outlined,
              color: Color(0xFF7C3AED),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Belum dikerjakan",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF0F2D6B),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Selesaikan placement test untuk mengetahui level awalmu.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacementResultCard extends ConsumerWidget {
  const _PlacementResultCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(placementResultProvider);
    return resultAsync.when(
      loading: () => Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7C3AED),
            strokeWidth: 2.5,
          ),
        ),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Gagal memuat hasil placement: $err',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ),
      data: (result) {
        final score = (result['score'] as num?)?.toDouble() ?? 0;
        final grade = result['grade'] as String? ?? '-';

        // RESTRUKTURISASI AMAN: Kembalikan fungsi privat bawaan asli milik Anda
        final info = _gradeInfo(grade);
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                info.color.withOpacity(0.12),
                info.color.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: info.color.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: info.color.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: info.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: info.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nilai: ${score.toStringAsFixed(1)}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(info.icon, color: info.color.withOpacity(0.5), size: 28),
            ],
          ),
        );
      },
    );
  }

  // REKONSILIASI METODE PRIVAT KELAS BAWAAN ASLI (ANTI GARIS MERAH)
  GradeVisual _gradeInfo(String grade) {
    switch (grade) {
      case 'A':
        return const GradeVisual(
          icon: Icons.emoji_events_rounded,
          color: Color(0xFFF59E0B),
          label: 'Sangat Memuaskan',
          description: 'Pemahaman sangat kuat. Siap materi paling menantang.',
        );
      case 'AB':
        return const GradeVisual(
          icon: Icons.star_rounded,
          color: Color(0xFF10B981),
          label: 'Memuaskan',
          description: 'Fondasi kuat untuk berkembang lebih jauh.',
        );
      case 'B':
        return const GradeVisual(
          icon: Icons.thumb_up_rounded,
          color: Color(0xFF1A56DB),
          label: 'Baik',
          description: 'Pemahaman baik. Terus berlatih untuk hasil optimal.',
        );
      case 'BC':
        return const GradeVisual(
          icon: Icons.trending_up_rounded,
          color: Color(0xFF6366F1),
          label: 'Cukup Baik',
          description: 'Di jalur yang tepat. Sedikit latihan lagi.',
        );
      case 'C':
        return const GradeVisual(
          icon: Icons.school_rounded,
          color: Color(0xFF8B5CF6),
          label: 'Cukup',
          description: 'Fokus pada konsep dasar untuk meningkat.',
        );
      case 'D':
        return const GradeVisual(
          icon: Icons.auto_graph_rounded,
          color: Color(0xFFF97316),
          label: 'Kurang',
          description: 'Mulai dari konsep dasar secara bertahap.',
        );
      default:
        return const GradeVisual(
          icon: Icons.refresh_rounded,
          color: Color(0xFFEF4444),
          label: 'Perlu Bimbingan',
          description: 'Manfaatkan semua materi dan jangan ragu bertanya.',
        );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final double avg;
  final double best;
  const _SummaryCard({
    required this.total,
    required this.avg,
    required this.best,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A40A8), Color(0xFF2D6EE8), Color(0xFF4B8EFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A5FD4).withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          _StatBox(
            label: "Total Sesi",
            value: "$total",
            icon: Icons.history_rounded,
          ),
          _VertDivider(),
          _StatBox(
            label: "Rata-rata",
            value: avg.toStringAsFixed(1),
            icon: Icons.trending_up_rounded,
          ),
          _VertDivider(),
          _StatBox(
            label: "Terbaik",
            value: best.toStringAsFixed(0),
            icon: Icons.emoji_events_rounded,
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatefulWidget {
  final dynamic session;
  final dynamic assignment;
  final int attempt;
  final VoidCallback onTap;
  const _SessionCard({
    required this.session,
    required this.assignment,
    required this.attempt,
    required this.onTap,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _pressed = false;
  Color _scoreColor(num score) => score >= 80
      ? const Color(0xFF1A8A5A)
      : (score >= 60 ? const Color(0xFF2D6EE8) : const Color(0xFFE53935));
  Color _scoreBg(num score) => score >= 80
      ? const Color(0xFFE8F8F2)
      : (score >= 60 ? const Color(0xFFEEF4FF) : const Color(0xFFFFEBEE));

  @override
  Widget build(BuildContext context) {
    final score = widget.session != null
        ? (widget.session['total_score'] ?? 0)
        : null;
    final title = widget.assignment['title'] ?? "Kuis";

    // PEMANDUAN VARIABEL AMAN: Ambil gembok password lewat widget induk secara mutlak
    final bool hasPassword =
        (widget.assignment['has_password'] ?? false) ||
        (widget.assignment['password'] != null);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B8EFF).withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: score != null
                        ? _scoreBg(score)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: score != null
                        ? Text(
                            "$score",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _scoreColor(score),
                            ),
                          )
                        : const Icon(
                            Icons.assignment_outlined,
                            color: Color(0xFF64748B),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF0F2D6B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasPassword)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.orange,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: score != null
                                  ? _scoreBg(score)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              score != null
                                  ? (score >= 80
                                        ? "Lulus"
                                        : (score >= 60
                                              ? "Cukup"
                                              : "Perlu Latihan"))
                                  : "Belum Diikuti",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: score != null
                                    ? _scoreColor(score)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.attempt > 0
                                ? "Percobaan: ${widget.attempt}x"
                                : "0 Percobaan",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF4B8EFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyQuizState extends StatelessWidget {
  const _EmptyQuizState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEAFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                size: 42,
                color: Color(0xFF2D6EE8),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Belum ada kuis tersedia",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F2D6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Dosen belum menerbitkan kuis aktif untuk kelas Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFE53935),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Gagal memuat riwayat",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF0F2D6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
