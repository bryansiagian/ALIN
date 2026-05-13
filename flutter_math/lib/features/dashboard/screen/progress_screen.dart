import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';
import 'package:flutter_math/features/exam/screen/exam_result_screen.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/placement/provider/placement_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
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
                    if (hasTakenPlacement) ref.invalidate(placementResultProvider);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 20),
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
              child: _PlacementSection(
                hasTakenPlacement: hasTakenPlacement,
              ),
            ),
          ),

          // ── Kuis Reguler Content ─────────────────────────────────────
          analyticsAsync.when(
            data: (data) {
              final sessions = data.sessions;
              if (sessions.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: const SliverFillRemaining(child: _EmptyQuizState()),
                );
              }

              final scores = sessions
                  .map<num>((s) => s['total_score'] ?? 0)
                  .toList();
              final avg =
                  scores.reduce((a, b) => a + b) / scores.length;
              final best = scores.reduce((a, b) => a > b ? a : b);

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return _SummaryCard(
                          total: sessions.length,
                          avg: avg.toDouble(),
                          best: best.toDouble(),
                        );
                      }
                      if (index == 1) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 20, bottom: 10),
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
                                      Color(0xFF1A5FD4)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Semua Sesi Ujian",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F2D6B),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${sessions.length} sesi",
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
                      final session = sessions[idx];
                      final assignment = session['assignment'];
                      final attempt = sessions.length - idx;
                      return _SessionCard(
                        session: session,
                        assignment: assignment,
                        attempt: attempt,
                        onTap: () =>
                            _viewDetail(context, session, assignment),
                      );
                    },
                    childCount: sessions.length + 2,
                  ),
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

  void _viewDetail(
      BuildContext context, dynamic session, dynamic assignment) {
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
}

// ── Placement Section ─────────────────────────────────────────────────────────
class _PlacementSection extends ConsumerWidget {
  final bool hasTakenPlacement;

  const _PlacementSection({required this.hasTakenPlacement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
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
          _PlacementResultCard(),
      ],
    );
  }
}

// Card: belum mengerjakan placement
class _PlacementNotTakenCard extends StatelessWidget {
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
            child: const Icon(Icons.quiz_outlined,
                color: Color(0xFF7C3AED), size: 24),
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

// Card: sudah mengerjakan placement — fetch hasilnya
class _PlacementResultCard extends ConsumerWidget {
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
            border: Border.all(
              color: info.color.withOpacity(0.25),
              width: 1.5,
            ),
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
              // Grade badge
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

              // Info
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

              // Icon
              Icon(info.icon, color: info.color.withOpacity(0.5), size: 28),
            ],
          ),
        );
      },
    );
  }

  _GradeVisual _gradeInfo(String grade) {
    switch (grade) {
      case 'A':
        return _GradeVisual(
          icon: Icons.emoji_events_rounded,
          color: const Color(0xFFF59E0B),
          label: 'Sangat Memuaskan',
          description: 'Pemahaman sangat kuat. Siap materi paling menantang.',
        );
      case 'AB':
        return _GradeVisual(
          icon: Icons.star_rounded,
          color: const Color(0xFF10B981),
          label: 'Memuaskan',
          description: 'Fondasi kuat untuk berkembang lebih jauh.',
        );
      case 'B':
        return _GradeVisual(
          icon: Icons.thumb_up_rounded,
          color: const Color(0xFF1A56DB),
          label: 'Baik',
          description: 'Pemahaman baik. Terus berlatih untuk hasil optimal.',
        );
      case 'BC':
        return _GradeVisual(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF6366F1),
          label: 'Cukup Baik',
          description: 'Di jalur yang tepat. Sedikit latihan lagi.',
        );
      case 'C':
        return _GradeVisual(
          icon: Icons.school_rounded,
          color: const Color(0xFF8B5CF6),
          label: 'Cukup',
          description: 'Fokus pada konsep dasar untuk meningkat.',
        );
      case 'D':
        return _GradeVisual(
          icon: Icons.auto_graph_rounded,
          color: const Color(0xFFF97316),
          label: 'Kurang',
          description: 'Mulai dari konsep dasar secara bertahap.',
        );
      default:
        return _GradeVisual(
          icon: Icons.refresh_rounded,
          color: const Color(0xFFEF4444),
          label: 'Perlu Bimbingan',
          description: 'Manfaatkan semua materi dan jangan ragu bertanya.',
        );
    }
  }
}

class _GradeVisual {
  final IconData icon;
  final Color color;
  final String label;
  final String description;

  const _GradeVisual({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
  });
}

// ── Summary Card ─────────────────────────────────────────────────────────────
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ringkasan Progres",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(
                  label: "Total Sesi",
                  value: "$total",
                  icon: Icons.history_rounded),
              _VertDivider(),
              _StatBox(
                  label: "Rata-rata",
                  value: avg.toStringAsFixed(1),
                  icon: Icons.trending_up_rounded),
              _VertDivider(),
              _StatBox(
                  label: "Terbaik",
                  value: best.toStringAsFixed(0),
                  icon: Icons.emoji_events_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.80), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: Colors.white.withOpacity(0.22),
    );
  }
}

// ── Session Card ─────────────────────────────────────────────────────────────
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

  Color _scoreColor(num score) {
    if (score >= 80) return const Color(0xFF1A8A5A);
    if (score >= 60) return const Color(0xFF2D6EE8);
    return const Color(0xFFE53935);
  }

  Color _scoreBg(num score) {
    if (score >= 80) return const Color(0xFFE8F8F2);
    if (score >= 60) return const Color(0xFFEEF4FF);
    return const Color(0xFFFFEBEE);
  }

  String _scoreLabel(num score) {
    if (score >= 80) return "Lulus";
    if (score >= 60) return "Cukup";
    return "Perlu Latihan";
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.session['total_score'] ?? 0;
    final title = widget.assignment['title'] ?? "Kuis";

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _scoreBg(score),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      "$score",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _scoreColor(score),
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
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F2D6B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _scoreBg(score),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              _scoreLabel(score),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _scoreColor(score),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Percobaan ke-${widget.attempt}",
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

// ── Empty States ──────────────────────────────────────────────────────────────
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
              child: const Icon(Icons.bar_chart_rounded,
                  size: 42, color: Color(0xFF2D6EE8)),
            ),
            const SizedBox(height: 18),
            const Text(
              "Belum ada riwayat kuis",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F2D6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Selesaikan kuis pertamamu untuk melihat progres di sini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
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
              child: const Icon(Icons.cloud_off_rounded,
                  color: Color(0xFFE53935), size: 36),
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