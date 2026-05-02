import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
const _kBlue900 = Color(0xFF0D2B6B);
const _kBlue700 = Color(0xFF1A56DB);
const _kBlue500 = Color(0xFF3B82F6);
const _kBlue200 = Color(0xFFBFDBFE);
const _kBlue50  = Color(0xFFEFF6FF);
const _kSurface = Color(0xFFF8FAFF);

// ─────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────
class AssignmentQuestionsScreen extends ConsumerStatefulWidget {
  final int assignmentId;
  final String title;

  const AssignmentQuestionsScreen({
    super.key,
    required this.assignmentId,
    required this.title,
  });

  @override
  ConsumerState<AssignmentQuestionsScreen> createState() => _AssignmentQuestionsScreenState();
}

class _AssignmentQuestionsScreenState extends ConsumerState<AssignmentQuestionsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List> _future;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  void _load() {
    final service = LecturerService(ref.read(apiClientProvider).dio);
    _future = service.getAssignmentQuestions(widget.assignmentId);
    _fadeCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: FutureBuilder<List>(
          future: _future,
          builder: (context, snapshot) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(snapshot),
                if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(child: _LoadingState())
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: _ErrorState(
                      error: snapshot.error.toString(),
                      onRetry: () => setState(_load),
                    ),
                  )
                else if ((snapshot.data ?? []).isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  _buildList(snapshot.data!),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(AsyncSnapshot snapshot) {
    final count = snapshot.data?.length ?? 0;

    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      stretch: true,
      backgroundColor: _kBlue700,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => setState(_load),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _AppBarBackground(title: widget.title, count: count),
      ),
    );
  }

  Widget _buildList(List questions) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.06 + index * 0.03),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _fadeCtrl,
                  curve: Interval(
                    (index * 0.07).clamp(0.0, 0.8),
                    1.0,
                    curve: Curves.easeOut,
                  ),
                )),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _QuestionCard(
                    question: questions[index],
                    index: index,
                    onEdit: () => _showEditSheet(context, ref, questions[index]),
                  ),
                ),
              ),
            );
          },
          childCount: questions.length,
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Map q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditQuestionSheet(
        question: q,
        onSave: (newText, newKey) async {
          await ref.read(lecturerServiceProvider).updateQuestion(q['id'], {
            'question_text': newText,
            'correct_answer': newKey,
          });
          if (context.mounted) {
            setState(_load); // Reload list
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1A1A2E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Color(0xFF6EE7B7), size: 18),
                    SizedBox(width: 10),
                    Text("Soal berhasil diperbarui!", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AppBar Background
// ─────────────────────────────────────────────
class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBlue900, _kBlue700, _kBlue500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Text(
                          "Bank Soal",
                          style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.quiz_outlined, color: Color(0xFFBFDBFE), size: 13),
                      const SizedBox(width: 6),
                      Text(
                        "$count Soal",
                        style: const TextStyle(
                          color: Color(0xFFBFDBFE),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Question Card
// ─────────────────────────────────────────────
class _QuestionCard extends StatefulWidget {
  const _QuestionCard({required this.question, required this.index, required this.onEdit});
  final Map question;
  final int index;
  final VoidCallback onEdit;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _expanded = false;

  static const _optionColors = [
    Color(0xFFEFF6FF), Color(0xFFF0FDF4),
    Color(0xFFFFFBEB), Color(0xFFFFF1F2),
  ];
  static const _optionBorderColors = [
    Color(0xFFBFDBFE), Color(0xFFBBF7D0),
    Color(0xFFFDE68A), Color(0xFFFFCDD2),
  ];
  static const _optionLabelColors = [
    _kBlue700, Color(0xFF16A34A),
    Color(0xFFD97706), Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final options = q['options'] as List? ?? [];
    final correctAnswer = q['correct_answer'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBlue200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _kBlue500.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kBlue700, _kBlue500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _kBlue500.withOpacity(0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${widget.index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Question text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q['question_text'] ?? '',
                        maxLines: _expanded ? null : 3,
                        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          height: 1.55,
                        ),
                      ),
                      if (!_expanded && (q['question_text'] ?? '').length > 100)
                        GestureDetector(
                          onTap: () => setState(() => _expanded = true),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "Selengkapnya",
                              style: TextStyle(
                                fontSize: 12,
                                color: _kBlue500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Edit button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onEdit();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFFD97706)),
                  ),
                ),
              ],
            ),
          ),

          // ── Options ──
          if (options.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Column(
                children: List.generate(options.length, (i) {
                  final opt = options[i];
                  final key = opt['key'] as String? ?? '';
                  final isCorrect = key == correctAnswer;
                  final colorIdx = i % 4;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCorrect ? const Color(0xFFF0FDF4) : _optionColors[colorIdx],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect ? const Color(0xFF86EFAC) : _optionBorderColors[colorIdx],
                        width: isCorrect ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isCorrect ? const Color(0xFF16A34A) : _optionLabelColors[colorIdx].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isCorrect ? Colors.white : _optionLabelColors[colorIdx],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt['text'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: isCorrect ? const Color(0xFF15803D) : const Color(0xFF334155),
                              fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCorrect)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],

          // ── Answer Key Footer ──
          Container(
            margin: const EdgeInsets.fromLTRB(18, 4, 18, 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.key_rounded, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                const Text(
                  "Kunci Jawaban: ",
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                Text(
                  correctAnswer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Edit Question Bottom Sheet
// ─────────────────────────────────────────────
class _EditQuestionSheet extends StatefulWidget {
  const _EditQuestionSheet({required this.question, required this.onSave});
  final Map question;
  final Future<void> Function(String newText, String newKey) onSave;

  @override
  State<_EditQuestionSheet> createState() => _EditQuestionSheetState();
}

class _EditQuestionSheetState extends State<_EditQuestionSheet> {
  late TextEditingController _controller;
  late String _selectedKey;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question['question_text'] ?? '');
    _selectedKey = widget.question['correct_answer'] ?? 'A';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kBlue700, _kBlue500]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                "Edit Soal",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Question Text Field
          const Text(
            "Teks Soal",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _kBlue50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBlue200),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.55),
              decoration: const InputDecoration(
                hintText: "Tulis teks soal di sini...",
                hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Correct Answer Selector
          const Text(
            "Kunci Jawaban",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['A', 'B', 'C', 'D'].map((key) {
              final selected = _selectedKey == key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKey = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(colors: [_kBlue700, _kBlue500])
                          : null,
                      color: selected ? null : _kBlue50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.transparent : _kBlue200,
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: _kBlue500.withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: selected ? Colors.white : _kBlue700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () async {
                          if (_controller.text.trim().isEmpty) return;
                          setState(() => _isSaving = true);
                          try {
                            await widget.onSave(_controller.text.trim(), _selectedKey);
                            if (mounted) Navigator.pop(context);
                          } catch (_) {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _isSaving
                          ? null
                          : const LinearGradient(colors: [_kBlue700, _kBlue500]),
                      color: _isSaving ? const Color(0xFFCBD5E1) : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isSaving
                          ? null
                          : [BoxShadow(color: _kBlue500.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Simpan Perubahan",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  State Screens
// ─────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kBlue50,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _kBlue200.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
          ),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(_kBlue500)),
          ),
        ),
        const SizedBox(height: 20),
        const Text("Memuat soal...", style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kBlue50,
                shape: BoxShape.circle,
                border: Border.all(color: _kBlue200, width: 2),
              ),
              child: const Icon(Icons.inbox_rounded, size: 48, color: _kBlue500),
            ),
            const SizedBox(height: 20),
            const Text("Belum Ada Soal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            const Text(
              "Soal untuk kuis ini belum ditambahkan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECACA), width: 2),
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 20),
            const Text("Gagal Memuat Soal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kBlue700, _kBlue500]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _kBlue500.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text("Coba Lagi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}