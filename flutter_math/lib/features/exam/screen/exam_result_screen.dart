import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
const _kBlue900 = Color(0xFF0D2B6B);
const _kBlue700 = Color(0xFF1A56DB);
const _kBlue500 = Color(0xFF3B82F6);
const _kBlue200 = Color(0xFFBFDBFE);
const _kBlue50  = Color(0xFFEFF6FF);
const _kSurface = Color(0xFFF8FAFF);

class ExamResultScreen extends StatefulWidget {
  final int score;
  final List questions;
  final Map<int, String> userAnswers;
  final bool canShowDetail;

  const ExamResultScreen({
    super.key,
    required this.score,
    required this.questions,
    required this.userAnswers,
    required this.canShowDetail,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _scoreAnim;

  int get _correct => widget.questions
      .where((q) => (widget.userAnswers[q['id']] ?? '') == q['correct_answer'])
      .length;

  int get _incorrect => widget.questions.length - _correct -
      widget.questions.where((q) => (widget.userAnswers[q['id']] ?? '') == '').length;

  int get _unanswered => widget.questions
      .where((q) => (widget.userAnswers[q['id']] ?? '') == '')
      .length;

  Color get _scoreColor {
    if (widget.score >= 80) return const Color(0xFF059669);
    if (widget.score >= 60) return _kBlue700;
    return const Color(0xFFEF4444);
  }

  String get _scoreLabel {
    if (widget.score >= 80) return "Lulus";
    if (widget.score >= 60) return "Cukup";
    return "Perlu Latihan";
  }

  IconData get _scoreIcon {
    if (widget.score >= 80) return Icons.emoji_events_rounded;
    if (widget.score >= 60) return Icons.thumb_up_rounded;
    return Icons.refresh_rounded;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut));
    _scoreAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _kSurface,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (widget.canShowDetail) ...[
                      _StatsRow(correct: _correct, incorrect: _incorrect, unanswered: _unanswered),
                      const SizedBox(height: 28),
                      const _SectionLabel(label: "Review Jawaban"),
                      const SizedBox(height: 14),
                      ...List.generate(widget.questions.length, (i) {
                        final q = widget.questions[i];
                        final userAns = widget.userAnswers[q['id']] ?? '';
                        final isCorrect = userAns == q['correct_answer'];
                        final isUnanswered = userAns.isEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ReviewCard(
                            index: i,
                            question: q,
                            userAnswer: userAns,
                            isCorrect: isCorrect,
                            isUnanswered: isUnanswered,
                          ),
                        );
                      }),
                    ] else
                      _HiddenResultCard(),
                    const SizedBox(height: 12),
                    _HomeButton(onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBlue900, _kBlue700, _kBlue500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              children: [
                // Icon animated
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(_scoreIcon, color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    widget.canShowDetail ? "Hasil Ujian Anda" : "Ujian Berhasil Dikirim",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                if (widget.canShowDetail) ...[
                  const SizedBox(height: 20),
                  // Score display
                  AnimatedBuilder(
                    animation: _scoreAnim,
                    builder: (_, __) {
                      final displayed = (widget.score * _scoreAnim.value).toInt();
                      return Column(
                        children: [
                          Text(
                            "$displayed",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            "dari 100",
                            style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  // Status badge
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: _scoreColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _scoreColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        _scoreLabel,
                        style: TextStyle(
                          color: widget.score >= 60 ? Colors.white : const Color(0xFFFCA5A5),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: const Text(
                      "Jawaban Anda telah berhasil disimpan",
                      style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 14),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Stats Row
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.correct, required this.incorrect, required this.unanswered});
  final int correct;
  final int incorrect;
  final int unanswered;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(value: correct, label: "Benar", color: const Color(0xFF059669), bg: const Color(0xFFF0FDF4)),
        const SizedBox(width: 10),
        _StatBox(value: incorrect, label: "Salah", color: const Color(0xFFEF4444), bg: const Color(0xFFFEF2F2)),
        const SizedBox(width: 10),
        _StatBox(value: unanswered, label: "Kosong", color: const Color(0xFF94A3B8), bg: const Color(0xFFF8FAFF)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, required this.color, required this.bg});
  final int value;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Section Label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kBlue700, _kBlue500], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Review Card
// ─────────────────────────────────────────────
class _ReviewCard extends StatefulWidget {
  const _ReviewCard({
    required this.index,
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
    required this.isUnanswered,
  });

  final int index;
  final Map question;
  final String userAnswer;
  final bool isCorrect;
  final bool isUnanswered;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  Color get _borderColor {
    if (widget.isUnanswered) return const Color(0xFFE2E8F0);
    return widget.isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
  }

  Color get _bgColor {
    if (widget.isUnanswered) return Colors.white;
    return widget.isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question['options'] as List? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: options.isNotEmpty ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number badge
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.isUnanswered
                          ? const Color(0xFFF1F5F9)
                          : widget.isCorrect
                              ? const Color(0xFF059669)
                              : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: widget.isUnanswered
                          ? Text("${widget.index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))
                          : Icon(widget.isCorrect ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.question['question_text'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        // Answer chips row
                        Row(
                          children: [
                            _AnswerChip(
                              label: "Jawaban Anda",
                              value: widget.userAnswer.isEmpty ? "—" : widget.userAnswer,
                              isCorrect: widget.isCorrect,
                              isUnanswered: widget.isUnanswered,
                            ),
                            const SizedBox(width: 8),
                            _AnswerChip(
                              label: "Kunci",
                              value: widget.question['correct_answer'] ?? '',
                              isCorrect: true,
                              isUnanswered: false,
                              forceGreen: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (options.isNotEmpty)
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 20),
                    ),
                ],
              ),
            ),
          ),

          // Expanded options
          if (_expanded && options.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  ...options.map((opt) {
                    final key = opt['key'] as String? ?? '';
                    final isUserAns = key == widget.userAnswer;
                    final isCorrectAns = key == widget.question['correct_answer'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCorrectAns
                            ? const Color(0xFFF0FDF4)
                            : isUserAns
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCorrectAns
                              ? const Color(0xFF86EFAC)
                              : isUserAns
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: isCorrectAns
                                  ? const Color(0xFF059669)
                                  : isUserAns
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(key, style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: (isCorrectAns || isUserAns) ? Colors.white : const Color(0xFF94A3B8),
                              )),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              opt['text'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isCorrectAns ? const Color(0xFF15803D) : const Color(0xFF334155),
                                fontWeight: isCorrectAns ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCorrectAns)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                          if (isUserAns && !isCorrectAns)
                            const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 16),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.value,
    required this.isCorrect,
    required this.isUnanswered,
    this.forceGreen = false,
  });

  final String label;
  final String value;
  final bool isCorrect;
  final bool isUnanswered;
  final bool forceGreen;

  @override
  Widget build(BuildContext context) {
    final Color color = forceGreen
        ? const Color(0xFF059669)
        : isUnanswered
            ? const Color(0xFF94A3B8)
            : isCorrect
                ? const Color(0xFF059669)
                : const Color(0xFFEF4444);

    final Color bg = forceGreen
        ? const Color(0xFFF0FDF4)
        : isUnanswered
            ? const Color(0xFFF1F5F9)
            : isCorrect
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFFEF2F2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Hidden Result Card
// ─────────────────────────────────────────────
class _HiddenResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBlue200, width: 1.5),
        boxShadow: [BoxShadow(color: _kBlue500.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            child: const Icon(Icons.visibility_off_rounded, color: Color(0xFFD97706), size: 36),
          ),
          const SizedBox(height: 18),
          const Text(
            "Detail Disembunyikan",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          const Text(
            "Terima kasih telah mengerjakan ujian. Skor dan detail jawaban Anda telah disimpan dan disembunyikan oleh dosen pengampu.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Home Button
// ─────────────────────────────────────────────
class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kBlue700, _kBlue500]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _kBlue500.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Kembali ke Beranda",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}