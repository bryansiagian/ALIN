import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/exam/screen/create_assignment_screen.dart';
import 'package:flutter_math/features/exam/screen/assignment_questions_screen.dart';

class LecturerDashboardScreen extends ConsumerWidget {
  const LecturerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(myAssignmentsProvider);
    final lecturerService = LecturerService(ref.watch(apiClientProvider).dio);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: assignmentsAsync.when(
        data: (assignments) => assignments.isEmpty
            ? _EmptyState(
                onCreateTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreateAssignmentScreen()),
                ),
              )
            : _AssignmentList(
                assignments: assignments,
                lecturerService: lecturerService,
                ref: ref,
                context: context,
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: Color(0xFF2D6EE8), strokeWidth: 3),
        ),
        error: (err, stack) => _ErrorState(message: err.toString()),
      ),
      floatingActionButton: _CreateFAB(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
        ),
      ),
    );
  }
}

// ── Assignment List ───────────────────────────────────────────────────────────
class _AssignmentList extends StatelessWidget {
  final List assignments;
  final LecturerService lecturerService;
  final WidgetRef ref;
  final BuildContext context;

  const _AssignmentList({
    required this.assignments,
    required this.lecturerService,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return RefreshIndicator(
      color: const Color(0xFF2D6EE8),
      onRefresh: () => ref.refresh(myAssignmentsProvider.future),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: assignments.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Daftar Kuis",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F2D6B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${assignments.length} kuis",
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          final task = assignments[index - 1];
          return _AssignmentCard(
            task: task,
            onViewResults: () => _showResults(
                context, ref, lecturerService, task.id),
            onViewQuestions: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssignmentQuestionsScreen(
                  assignmentId: task.id,
                  title: task.title,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showResults(BuildContext ctx, WidgetRef ref,
      LecturerService service, int id) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultsSheet(service: service, assignmentId: id),
    );
  }
}

// ── Assignment Card ───────────────────────────────────────────────────────────
class _AssignmentCard extends StatefulWidget {
  final dynamic task;
  final VoidCallback onViewResults;
  final VoidCallback onViewQuestions;

  const _AssignmentCard({
    required this.task,
    required this.onViewResults,
    required this.onViewQuestions,
  });

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isSafe = task.isSafeExam as bool;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B8EFF).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSafe
                              ? [
                                  const Color(0xFFFF6B6B),
                                  const Color(0xFFE53935)
                                ]
                              : [
                                  const Color(0xFF4B8EFF),
                                  const Color(0xFF1A5FD4)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isSafe ? Icons.security_rounded : Icons.assignment_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title + badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Color(0xFF0F2D6B),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (isSafe)
                                _Badge(
                                    label: "Safe Exam",
                                    color: const Color(0xFFFFEBEE),
                                    textColor: const Color(0xFFE53935)),
                              if (!isSafe)
                                _Badge(
                                    label: "Reguler",
                                    color: const Color(0xFFEEF4FF),
                                    textColor: const Color(0xFF2D6EE8)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Menu
                    _ContextMenu(
                      onViewResults: widget.onViewResults,
                      onViewQuestions: widget.onViewQuestions,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFFEEF4FF)),
                const SizedBox(height: 10),

                // ── Deadline ───────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: Color(0xFF4B8EFF)),
                    const SizedBox(width: 5),
                    Text(
                      "Deadline: ${task.deadline}",
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Badge(
      {required this.label,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(7)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor)),
    );
  }
}

// ── Context Menu ──────────────────────────────────────────────────────────────
class _ContextMenu extends StatelessWidget {
  final VoidCallback onViewResults;
  final VoidCallback onViewQuestions;
  const _ContextMenu(
      {required this.onViewResults, required this.onViewQuestions});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'results') onViewResults();
        if (val == 'questions') onViewQuestions();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F6FF),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(Icons.more_horiz_rounded,
            color: Color(0xFF4B8EFF), size: 18),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'results',
          child: Row(
            children: const [
              Icon(Icons.bar_chart_rounded,
                  color: Color(0xFF2D6EE8), size: 18),
              SizedBox(width: 10),
              Text("Lihat Hasil & Skor",
                  style: TextStyle(
                      fontSize: 13.5, color: Color(0xFF0F2D6B))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'questions',
          child: Row(
            children: const [
              Icon(Icons.list_alt_rounded,
                  color: Color(0xFF2D6EE8), size: 18),
              SizedBox(width: 10),
              Text("Lihat Soal",
                  style: TextStyle(
                      fontSize: 13.5, color: Color(0xFF0F2D6B))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Create FAB ────────────────────────────────────────────────────────────────
class _CreateFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A5FD4).withOpacity(0.38),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Buat Kuis SEB",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results Bottom Sheet ──────────────────────────────────────────────────────
class _ResultsSheet extends StatelessWidget {
  final LecturerService service;
  final int assignmentId;
  const _ResultsSheet(
      {required this.service, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bar_chart_rounded,
                          color: Color(0xFF2D6EE8), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Hasil & Skor Mahasiswa",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F2D6B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFEEF4FF)),
              ],
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder(
              future: service.getAssignmentResults(assignmentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2D6EE8), strokeWidth: 3),
                  );
                }
                final data = snapshot.data as List? ?? [];
                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEAFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.people_outline_rounded,
                              color: Color(0xFF2D6EE8), size: 32),
                        ),
                        const SizedBox(height: 12),
                        const Text("Belum ada mahasiswa",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F2D6B))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: data.length,
                  itemBuilder: (ctx, i) {
                    final group = data[i];
                    final user = group['user'];
                    final best = group['highest_score'];
                    final attempts = group['total_attempts'];
                    final initial =
                        (user['name'] as String)[0].toUpperCase();

                    return GestureDetector(
                      onTap: () => _showAttempts(
                          context, group['attempts'], user['name']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFDCEAFF), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4B8EFF),
                                    Color(0xFF1A5FD4)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Center(
                                child: Text(initial,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(user['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                          color: Color(0xFF0F2D6B))),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      _MiniStat(
                                          icon: Icons.emoji_events_rounded,
                                          label: "Terbaik: $best"),
                                      const SizedBox(width: 12),
                                      _MiniStat(
                                          icon: Icons.repeat_rounded,
                                          label: "$attempts Percobaan"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF4B8EFF)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAttempts(
      BuildContext context, List attempts, String studentName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AttemptsSheet(attempts: attempts, studentName: studentName),
    );
  }
}

// ── Mini Stat ─────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF4B8EFF)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 11.5, color: Colors.grey[600])),
      ],
    );
  }
}

// ── Attempts Sheet ────────────────────────────────────────────────────────────
class _AttemptsSheet extends StatelessWidget {
  final List attempts;
  final String studentName;
  const _AttemptsSheet(
      {required this.attempts, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F6FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4B8EFF),
                            Color(0xFF1A5FD4)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          studentName[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF0F2D6B),
                            ),
                          ),
                          Text(
                            "${attempts.length} percobaan ujian",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: attempts.length,
              itemBuilder: (ctx, i) {
                final session = attempts[i];
                final score = session['total_score'];
                final violations = session['violation_count'];
                final attemptNum = attempts.length - i;

                Color scoreColor;
                if (score >= 80) scoreColor = const Color(0xFF1A8A5A);
                else if (score >= 60) scoreColor = const Color(0xFF2D6EE8);
                else scoreColor = const Color(0xFFE53935);

                return GestureDetector(
                  onTap: () =>
                      _showAnswers(ctx, session['answers']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF4B8EFF).withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Score bubble
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              "$score",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Percobaan ke-$attemptNum",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: Color(0xFF0F2D6B),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  if (violations > 0)
                                    _MiniStat(
                                      icon: Icons.warning_amber_rounded,
                                      label: "$violations Pelanggaran",
                                    )
                                  else
                                    _MiniStat(
                                      icon: Icons.verified_rounded,
                                      label: "Tanpa Pelanggaran",
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
                              color: Color(0xFF4B8EFF)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAnswers(BuildContext context, List answers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnswersSheet(answers: answers),
    );
  }
}

// ── Answers Sheet ─────────────────────────────────────────────────────────────
class _AnswersSheet extends StatelessWidget {
  final List answers;
  const _AnswersSheet({required this.answers});

  @override
  Widget build(BuildContext context) {
    final correct = answers.where((a) => a['is_correct'] == 1).length;
    final total = answers.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Detail Jawaban",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F2D6B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: correct == total
                            ? const Color(0xFFE8F8F2)
                            : const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$correct / $total Benar",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: correct == total
                              ? const Color(0xFF1A8A5A)
                              : const Color(0xFF2D6EE8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFEEF4FF)),
              ],
            ),
          ),

          // Answer list
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: answers.length,
              itemBuilder: (ctx, i) {
                final ans = answers[i];
                final isCorrect = ans['is_correct'] == 1;
                final question = ans['question'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFF0FBF6)
                        : const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFFB2DFDB)
                          : const Color(0xFFFFCDD2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text + result icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              question['question_text'] ?? "Soal",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                color: Color(0xFF0F2D6B),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? const Color(0xFF1A8A5A)
                                  : const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isCorrect
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Answers
                      _AnswerRow(
                          label: "Jawaban",
                          value: ans['user_answer'],
                          isCorrect: isCorrect),
                      const SizedBox(height: 4),
                      _AnswerRow(
                          label: "Kunci",
                          value: question['correct_answer'],
                          isKey: true),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Answer Row ────────────────────────────────────────────────────────────────
class _AnswerRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCorrect;
  final bool isKey;

  const _AnswerRow({
    required this.label,
    required this.value,
    this.isCorrect = false,
    this.isKey = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isKey
                ? const Color(0xFF1A8A5A)
                : isCorrect
                    ? const Color(0xFF1A8A5A)
                    : const Color(0xFFE53935),
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

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
              child: const Icon(Icons.assignment_outlined,
                  size: 42, color: Color(0xFF2D6EE8)),
            ),
            const SizedBox(height: 18),
            const Text(
              "Belum ada kuis",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F2D6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Buat kuis pertamamu dan mulai menilai mahasiswa.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onCreateTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A5FD4).withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  "Buat Kuis Sekarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
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
              "Gagal memuat kuis",
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