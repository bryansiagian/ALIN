import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/guard/seb_guard.dart';
import 'package:flutter_math/features/exam/service/exam_service.dart';
import 'package:flutter_math/features/exam/screen/exam_result_screen.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';

class ExamScreen extends ConsumerStatefulWidget {
  final int sessionId;
  final List questions;
  final int duration;
  final bool showResults;

  const ExamScreen({super.key, required this.sessionId, required this.questions, required this.duration, required this.showResults,});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  late SEBGuard _sebGuard;
  int _currentIndex = 0;
  final Map<int, String> _answers = {}; 

  @override
  void initState() {
    super.initState();
    _sebGuard = SEBGuard(
      ref.read(violationReporterProvider),
      sessionId: widget.sessionId,
      onLocked: () => _handleLocked(),
    );
  }

  void _handleLocked() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Kecurangan Terdeteksi!"),
        content: const Text("Akun ujian Anda dikunci karena terlalu banyak pelanggaran."),
        actions: [TextButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text("Keluar"))],
      ),
    );
  }

  void _submitExam() async {
    int correct = 0;
    Map<String, String> finalAnswers = {};
    
    for (var q in widget.questions) {
      String? ans = _answers[q['id']];
      finalAnswers[q['id'].toString()] = ans ?? "";
      if (ans == q['correct_answer']) correct++;
    }
    
    int score = ((correct / widget.questions.length) * 100).toInt();

    try {
      // Sekarang memanggil dengan named parameters yang sudah kita buat di Service
      await ref.read(examServiceProvider).submitExam(
        sessionId: widget.sessionId, 
        score: score,
        answers: finalAnswers,
      );

      ref.invalidate(analyticsProvider);   // Refresh tab Progres
      ref.invalidate(examServiceProvider); // Refresh daftar kuis (AssignmentList)

      if (mounted) {
        ref.invalidate(examServiceProvider);
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (c) => ExamResultScreen(
            score: score, 
            questions: widget.questions, 
            userAnswers: _answers, 
            // AMBIL DARI SETTINGAN DOSEN:
            canShowDetail: widget.showResults, 
          ))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.questions[_currentIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Soal ${_currentIndex + 1} / ${widget.questions.length}"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currentQ['question_text'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...(currentQ['options'] as List).map((opt) {
                return RadioListTile<String>(
                  title: Text("${opt['key']}. ${opt['text']}"),
                  value: opt['key'],
                  groupValue: _answers[currentQ['id']],
                  onChanged: (val) => setState(() => _answers[currentQ['id']] = val!),
                );
              }),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(onPressed: () => setState(() => _currentIndex--), child: const Text("Kembali")),
                  if (_currentIndex < widget.questions.length - 1)
                    ElevatedButton(onPressed: () => setState(() => _currentIndex++), child: const Text("Lanjut"))
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: _submitExam, 
                      child: const Text("Selesai & Submit")
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sebGuard.dispose();
    super.dispose();
  }
}