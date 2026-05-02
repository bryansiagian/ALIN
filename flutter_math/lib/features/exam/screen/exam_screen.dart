import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/guard/seb_guard.dart';
import 'package:flutter_math/features/exam/service/exam_service.dart';
import 'package:flutter_math/features/exam/screen/exam_result_screen.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';

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
class ExamScreen extends ConsumerStatefulWidget {
  final int sessionId;
  final List questions;
  final int duration;
  final bool showResults;

  const ExamScreen({
    super.key,
    required this.sessionId,
    required this.questions,
    required this.duration,
    required this.showResults,
  });

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen>
    with SingleTickerProviderStateMixin {
  late SEBGuard _sebGuard;
  int _currentIndex = 0;
  final Map<int, String> _answers = {};
  bool _isSubmitting = false;

  // Timer
  late int _remainingSeconds;
  Timer? _timer;

  // Page transition animation
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _goingForward = true;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.duration * 60;

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _slideCtrl.forward();

    if (widget.duration > 0) _startTimer();

    _sebGuard = SEBGuard(
      ref.read(violationReporterProvider),
      sessionId: widget.sessionId,
      onLocked: _handleLocked,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _submitExam();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _timerDisplay {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return const Color(0xFFEF4444);
    if (_remainingSeconds <= 300) return const Color(0xFFF59E0B);
    return _kBlue500;
  }

  void _navigateTo(int index) {
    if (index == _currentIndex) return;
    _goingForward = index > _currentIndex;
    setState(() => _currentIndex = index);
    _slideCtrl.forward(from: 0);
  }

  void _handleLocked() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFFEF4444), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Akun Dikunci",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Akun ujian Anda dikunci karena terlalu banyak pelanggaran terdeteksi.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitConfirm() {
    final unanswered = widget.questions.length - _answers.length;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubmitConfirmSheet(
        total: widget.questions.length,
        answered: _answers.length,
        unanswered: unanswered,
        onSubmit: _submitExam,
      ),
    );
  }

  Future<void> _submitExam() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    int correct = 0;
    final Map<String, String> finalAnswers = {};
    for (var q in widget.questions) {
      final String? ans = _answers[q['id']];
      finalAnswers[q['id'].toString()] = ans ?? '';
      if (ans == q['correct_answer']) correct++;
    }
    final int score = ((correct / widget.questions.length) * 100).toInt();

    try {
      await ref.read(examServiceProvider).submitExam(
        sessionId: widget.sessionId,
        score: score,
        answers: finalAnswers,
      );

      ref.invalidate(analyticsProvider);
      ref.invalidate(examServiceProvider);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(
              score: score,
              questions: widget.questions,
              userAnswers: _answers,
              canShowDetail: widget.showResults,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text("Gagal submit: $e", style: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideCtrl.dispose();
    _sebGuard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.questions[_currentIndex];
    final total = widget.questions.length;
    final answeredCount = _answers.length;
    final progress = answeredCount / total;

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: _kSurface,
          body: SafeArea(
            child: Column(
              children: [
                _ExamHeader(
                  currentIndex: _currentIndex,
                  total: total,
                  answeredCount: answeredCount,
                  progress: progress,
                  timerDisplay: widget.duration > 0 ? _timerDisplay : null,
                  timerColor: _timerColor,
                  isWarning: _remainingSeconds <= 60 && widget.duration > 0,
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _goingForward
                          ? _slideAnim
                          : Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut)),
                      child: _QuestionBody(
                        question: currentQ,
                        selectedAnswer: _answers[currentQ['id']],
                        onAnswerSelected: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _answers[currentQ['id']] = val);
                        },
                      ),
                    ),
                  ),
                ),
                _QuestionNavigator(
                  currentIndex: _currentIndex,
                  total: total,
                  answers: _answers,
                  questions: widget.questions,
                  onNavigate: _navigateTo,
                ),
                _BottomActions(
                  currentIndex: _currentIndex,
                  total: total,
                  isSubmitting: _isSubmitting,
                  onPrev: () => _navigateTo(_currentIndex - 1),
                  onNext: () => _navigateTo(_currentIndex + 1),
                  onSubmit: _showSubmitConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────
class _ExamHeader extends StatelessWidget {
  const _ExamHeader({
    required this.currentIndex,
    required this.total,
    required this.answeredCount,
    required this.progress,
    required this.timerDisplay,
    required this.timerColor,
    required this.isWarning,
  });

  final int currentIndex;
  final int total;
  final int answeredCount;
  final double progress;
  final String? timerDisplay;
  final Color timerColor;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBlue900, _kBlue700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              // Soal counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Soal", style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12)),
                    Text(
                      "${currentIndex + 1} / $total",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Timer
              if (timerDisplay != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isWarning ? const Color(0xFFEF4444).withOpacity(0.15) : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isWarning ? const Color(0xFFEF4444).withOpacity(0.5) : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isWarning ? Icons.warning_amber_rounded : Icons.timer_outlined,
                        color: isWarning ? const Color(0xFFEF4444) : Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timerDisplay!,
                        style: TextStyle(
                          color: isWarning ? const Color(0xFFEF4444) : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(
                progress == 1.0 ? const Color(0xFF6EE7B7) : Colors.white,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$answeredCount dijawab",
                style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 11),
              ),
              Text(
                "${(progress * 100).toInt()}% selesai",
                style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Question Body
// ─────────────────────────────────────────────
class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  final Map question;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  static const _optionGradients = [
    [Color(0xFF1A56DB), Color(0xFF3B82F6)],
    [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    [Color(0xFF0D9488), Color(0xFF14B8A6)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
  ];

  @override
  Widget build(BuildContext context) {
    final options = question['options'] as List? ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBlue200, width: 1.2),
              boxShadow: [
                BoxShadow(color: _kBlue500.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              question['question_text'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Pilih jawaban:",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // Options
          ...List.generate(options.length, (i) {
            final opt = options[i];
            final key = opt['key'] as String? ?? '';
            final isSelected = selectedAnswer == key;
            final gradient = _optionGradients[i % _optionGradients.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionTile(
                optionKey: key,
                text: opt['text'] ?? '',
                isSelected: isSelected,
                gradient: gradient,
                onTap: () => onAnswerSelected(key),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  const _OptionTile({
    required this.optionKey,
    required this.text,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  final String optionKey;
  final String text;
  final bool isSelected;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.97, upperBound: 1.0, value: 1.0);
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(colors: widget.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: widget.isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected ? Colors.transparent : _kBlue200,
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [BoxShadow(color: widget.gradient[0].withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.isSelected ? Colors.white.withOpacity(0.22) : _kBlue50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.optionKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: widget.isSelected ? Colors.white : _kBlue700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
              ),
              if (widget.isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Question Navigator (dot grid)
// ─────────────────────────────────────────────
class _QuestionNavigator extends StatelessWidget {
  const _QuestionNavigator({
    required this.currentIndex,
    required this.total,
    required this.answers,
    required this.questions,
    required this.onNavigate,
  });

  final int currentIndex;
  final int total;
  final Map<int, String> answers;
  final List questions;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Navigasi Soal", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: total,
              itemBuilder: (_, i) {
                final isActive = i == currentIndex;
                final isAnswered = answers.containsKey(questions[i]['id']);

                return GestureDetector(
                  onTap: () => onNavigate(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 42 : 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(colors: [_kBlue700, _kBlue500])
                          : null,
                      color: isActive ? null : isAnswered ? _kBlue50 : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive ? Colors.transparent : isAnswered ? _kBlue200 : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(color: _kBlue500.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "${i + 1}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : isAnswered ? _kBlue700 : const Color(0xFF94A3B8),
                        ),
                      ),
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
}

// ─────────────────────────────────────────────
//  Bottom Actions
// ─────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.currentIndex,
    required this.total,
    required this.isSubmitting,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentIndex;
  final int total;
  final bool isSubmitting;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == total - 1;
    final isFirst = currentIndex == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Row(
        children: [
          // Prev
          AnimatedOpacity(
            opacity: isFirst ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: isFirst ? null : onPrev,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: _kBlue50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBlue200),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded, color: _kBlue700, size: 14),
                    SizedBox(width: 6),
                    Text("Kembali", style: TextStyle(color: _kBlue700, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Next / Submit
          if (!isLast)
            GestureDetector(
              onTap: onNext,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kBlue700, _kBlue500]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _kBlue500.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Lanjut", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: isSubmitting ? null : onSubmit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSubmitting
                      ? null
                      : const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                  color: isSubmitting ? const Color(0xFFCBD5E1) : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSubmitting
                      ? null
                      : [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text("Selesai & Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Submit Confirm Sheet
// ─────────────────────────────────────────────
class _SubmitConfirmSheet extends StatelessWidget {
  const _SubmitConfirmSheet({
    required this.total,
    required this.answered,
    required this.unanswered,
    required this.onSubmit,
  });

  final int total;
  final int answered;
  final int unanswered;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: unanswered > 0 ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unanswered > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
              color: unanswered > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            unanswered > 0 ? "Masih Ada Soal Kosong" : "Siap Submit?",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              children: [
                TextSpan(text: "Terjawab: ", children: [
                  TextSpan(text: "$answered", style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                  TextSpan(text: " / $total soal"),
                ]),
                if (unanswered > 0) ...[
                  const TextSpan(text: "\n"),
                  TextSpan(text: "$unanswered soal belum dijawab", style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                  const TextSpan(text: " akan dihitung kosong."),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
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
                      child: Text("Periksa Lagi", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onSubmit();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text("Ya, Submit!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
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