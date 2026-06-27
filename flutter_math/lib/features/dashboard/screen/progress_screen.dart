import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';
import 'package:flutter_math/features/exam/screen/exam_result_screen.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/placement/provider/placement_provider.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:dio/dio.dart';

import 'progress_screen_visual.dart';
import 'progress_screen_helpers.dart';

// ── PROVIDER MANDIRI (SOLUSI JELAS KUIS BARU) ──
final studentAssignmentsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.dio.get('/exam/assignments');
  return response.data as List<dynamic>;
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final assignmentsAsync = ref.watch(studentAssignmentsProvider);

    final user = ref.watch(authProvider).user;
    final hasTakenPlacement = user?.hasTakenPlacement ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar Premium ──
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
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(22, 12, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Riwayat Aktivitas",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Pantau perkembangan belajarmu",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Placement Result Section (Fitur Utuh) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PlacementSection(hasTakenPlacement: hasTakenPlacement),
            ),
          ),

          // ── Content Logic & List ──
          analyticsAsync.when(
            data: (analyticsData) {
              final sessions = analyticsData.sessions;
              return assignmentsAsync.when(
                data: (assignments) {
                  if (assignments.isEmpty) {
                    return const SliverFillRemaining(child: _EmptyQuizState());
                  }

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
                          return _buildHeaderList(assignments.length);
                        }

                        final idx = index - 2;
                        final assignment = assignments[idx];
                        final matchingSessions = sessions
                            .where(
                              (s) => s['assignment_id'] == assignment['id'],
                            )
                            .toList();
                        final latestSession = matchingSessions.isNotEmpty
                            ? matchingSessions.first
                            : null;

                        return _SessionCard(
                          session: latestSession,
                          assignment: assignment,
                          attempt:
                              assignment['exam_sessions_count'] ??
                              matchingSessions.length,
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
                loading: () =>
                    const SliverFillRemaining(child: _LoadingState()),
                error: (err, _) => SliverFillRemaining(
                  child: _ErrorState(message: err.toString()),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: _LoadingState()),
            error: (err, _) => SliverFillRemaining(
              child: _ErrorState(message: err.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderList(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
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
            "$count kuis",
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ── LOGIC HANDLERS (FUNGSI ASLI TIDAK BERUBAH) ──
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

    final String? startTimeStr = assignment['start_time'];
    final String? deadlineStr = assignment['deadline'];

    if (startTimeStr != null) {
      final DateTime startTime = DateTime.parse(startTimeStr).toLocal();
      print('startTime (raw): $startTime');
      print('startTime (local): ${startTime.toLocal()}');
      print('now: ${DateTime.now()}');
      print('isBefore: ${DateTime.now().isBefore(startTime)}');
      if (DateTime.now().isBefore(startTime)) {
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
            content: Text(
              "Akses ditolak: Hanya dibuka $startFormatted s/d $deadlineFormatted.",
            ),
          ),
        );
        return;
      }
    }

    if (session == null) {
      _challengeQuizPassword(context, ref, assignmentId, assignment);
      return;
    }

    if (allowReattempt && totalCompletedAttempts < attemptLimit) {
      _showReattemptSheet(
        context,
        ref,
        session,
        assignment,
        totalCompletedAttempts,
        attemptLimit,
      );
    } else {
      _viewDetail(context, session, assignment);
    }
  }

  void _showReattemptSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
    dynamic assignment,
    int current,
    int limit,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              leading: const Icon(Icons.replay_rounded, color: Colors.green),
              title: Text(
                "Mulai Percobaan Baru (${current + 1}/$limit)",
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
                  assignment['id'],
                  assignment,
                );
              },
            ),
          ],
        ),
      ),
    );
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
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Password Diperlukan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password Kuis",
              prefixIcon: Icon(Icons.vpn_key_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeStartExamNetworkCall(
                  context,
                  ref,
                  assignmentId,
                  passwordController.text.trim(),
                );
              },
              child: const Text("Masuk"),
            ),
          ],
        ),
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
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.dio.post(
        '/exam/assignments/$assignmentId/start',
        data: password != null ? {'password': password} : null,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Berhasil memulai kuis!"),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Gagal terhubung ke ruang ujian."),
          ),
        );
      }
    }
  }

  void _viewDetail(BuildContext context, dynamic session, dynamic assignment) {
    Map<int, String> userAnswers = {};
    for (var a in (session['answers'] ?? [])) {
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
      final DateTime dt = DateTime.parse(dateTimeStr).toLocal(); // ✅
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year} pukul '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTimeStr ?? '-';
    }
  }
}

// ── SUB-WIDGETS (DESIGN TARGET) ──

class _StatBox extends StatelessWidget {
  final String label, value;
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
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
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
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36,
    margin: const EdgeInsets.symmetric(horizontal: 14),
    color: Colors.white24,
  );
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final double avg, best;
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
          const _VertDivider(),
          _StatBox(
            label: "Rata-rata",
            value: avg.toStringAsFixed(1),
            icon: Icons.trending_up_rounded,
          ),
          const _VertDivider(),
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
          const _PlacementNotTakenCard()
        else
          const _PlacementResultCard(),
      ],
    );
  }
}

// ── KARTU HASIL PLACEMENT (LOGIKANYA TETAP UTUH) ──
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
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text('Gagal: $err'),
      ),
      data: (result) {
        final grade = result['grade'] as String? ?? '-';
        final score = (result['score'] as num?)?.toDouble() ?? 0;
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
            ),
            border: Border.all(color: info.color.withOpacity(0.25), width: 1.5),
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
                    Text(
                      "Nilai: ${score.toStringAsFixed(1)}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      info.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
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

  GradeVisual _gradeInfo(String grade) {
    switch (grade) {
      case 'A':
        return const GradeVisual(
          icon: Icons.emoji_events_rounded,
          color: Color(0xFFF59E0B),
          label: 'Sangat Memuaskan',
          description: 'Pemahaman sangat kuat.',
        );
      case 'AB':
        return const GradeVisual(
          icon: Icons.star_rounded,
          color: Color(0xFF10B981),
          label: 'Memuaskan',
          description: 'Fondasi kuat.',
        );
      case 'B':
        return const GradeVisual(
          icon: Icons.thumb_up_rounded,
          color: Color(0xFF1A56DB),
          label: 'Baik',
          description: 'Terus berlatih.',
        );
      case 'BC':
        return const GradeVisual(
          icon: Icons.trending_up_rounded,
          color: Color(0xFF6366F1),
          label: 'Cukup Baik',
          description: 'Di jalur yang tepat.',
        );
      case 'C':
        return const GradeVisual(
          icon: Icons.school_rounded,
          color: Color(0xFF8B5CF6),
          label: 'Cukup',
          description: 'Fokus pada dasar.',
        );
      case 'D':
        return const GradeVisual(
          icon: Icons.auto_graph_rounded,
          color: Color(0xFFF97316),
          label: 'Kurang',
          description: 'Mulai perlahan.',
        );
      default:
        return const GradeVisual(
          icon: Icons.refresh_rounded,
          color: Color(0xFFEF4444),
          label: 'Perlu Bimbingan',
          description: 'Jangan ragu bertanya.',
        );
    }
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
      ),
      child: const Row(
        children: [
          Icon(Icons.quiz_outlined, color: Color(0xFF7C3AED)),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Selesaikan placement test untuk mengetahui level awalmu.",
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── KARTU SESI (CODE UTUH TIDAK DIKURANGI) ──
class _SessionCard extends StatefulWidget {
  final dynamic session, assignment;
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
    final bool hasPassword =
        (widget.assignment['has_password'] ?? false) ||
        (widget.assignment['password'] != null);

    // ✅ TAMBAH: cek apakah belum waktunya
    final String? startTimeStr = widget.assignment['start_time'];
    final bool isLocked =
        startTimeStr != null &&
        DateTime.now().isBefore(DateTime.parse(startTimeStr).toLocal());
    final String? deadlineStr = widget.assignment['deadline'];

    return GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _pressed = true),
      onTapUp: isLocked
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: isLocked ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: isLocked ? 0.55 : 1.0, // ✅ redup jika terkunci
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFFF1F5F9)
                  : Colors.white, // ✅ abu jika terkunci
              borderRadius: BorderRadius.circular(18),
              boxShadow: isLocked
                  ? []
                  : [
                      // ✅ hapus shadow jika terkunci
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
                  // ✅ Icon kunci jika locked, skor jika tidak
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? const Color(0xFFE2E8F0)
                          : (score != null
                                ? _scoreBg(score)
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(
                              Icons.lock_clock_rounded,
                              color: Color(0xFF94A3B8),
                              size: 26,
                            )
                          : (score != null
                                ? Text(
                                    '$score',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: _scoreColor(score),
                                    ),
                                  )
                                : const Icon(
                                    Icons.assignment_outlined,
                                    color: Color(0xFF64748B),
                                  )),
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
                                widget.assignment['title'] ?? "Kuis",
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
                        if (isLocked) ...[
                          // ✅ Label waktu buka
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3CD),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Text(
                                  "Belum Dibuka",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92610A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Buka ${_formatTime(startTimeStr)}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
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
                      ],
                    ),
                  ),
                  Icon(
                    isLocked
                        ? Icons
                              .block_rounded // ✅ icon blocked jika terkunci
                        : Icons.arrow_forward_ios_rounded,
                    size: isLocked ? 16 : 13,
                    color: isLocked
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF4B8EFF),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Helper format waktu ringkas untuk label card
  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '-';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }
}

class _EmptyQuizState extends StatelessWidget {
  const _EmptyQuizState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      "Belum ada kuis tersedia",
      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2D6B)),
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Color(0xFF1A5FD4)));
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}
