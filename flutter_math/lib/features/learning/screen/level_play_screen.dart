import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/repository/level_repository.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';

class LevelPlayScreen extends ConsumerStatefulWidget {
  final int level;

  const LevelPlayScreen({Key? key, required this.level}) : super(key: key);

  @override
  ConsumerState<LevelPlayScreen> createState() => _LevelPlayScreenState();
}

class _LevelPlayScreenState extends ConsumerState<LevelPlayScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _questions = [];
  String _topicTitle = '';

  int _currentIndex = 0;
  String? _selectedOption;
  final List<Map<String, dynamic>> _userAnswers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // 1. Mengambil data soal dari Laravel via Riverpod Repository
  void _loadQuestions() async {
    try {
      final repo = ref.read(levelRepositoryProvider);
      final data = await repo.getQuestionsByLevel(widget.level);
      setState(() {
        _questions = data['questions'] ?? [];
        _topicTitle = data['topic_title'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 2. Berpindah soal atau memicu submit jika sudah di ujung soal
  void _nextQuestion() {
    if (_selectedOption == null) return;

    // Catat jawaban siswa untuk soal saat ini
    _userAnswers.add({
      'question_id': _questions[_currentIndex]['id'],
      'selected_option': _selectedOption,
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null; // Reset pilihan untuk soal berikutnya
      });
    } else {
      _submitQuiz();
    }
  }

  // 3. Mengirim seluruh kargo jawaban ke server Laravel
  void _submitQuiz() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(levelRepositoryProvider);
      final result = await repo.submitLevelResult(
        level: widget.level,
        answers: _userAnswers,
      );

      setState(() => _isSubmitting = false);
      _showResultDialog(result);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirimkan jawaban: $e')));
    }
  }

  // 4. Memunculkan Pop-up Kelulusan bergaya permainan (Gamification)
  void _showResultDialog(Map<String, dynamic> result) {
    final bool isPassed = result['is_passed'] ?? false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isPassed ? '🎉 Level Berhasil Dilewati!' : '😢 Belum Berhasil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPassed ? Colors.green : Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result['message'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              'Skor Anda: ${result['score']}%\nBenar: ${result['correct_answers']} dari 5 Soal',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPassed ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // --- TONGKAT COMPASS REAKTIF BARU ---
                ref.invalidate(
                  analyticsProvider,
                ); // Hancurkan memori induk, otomatis anak-anaknya ikut ter-update live!
                // ------------------------------------

                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke peta level utama
              },
              child: const Text(
                'KEMBALI KE PETA',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_errorMessage != null)
      return Scaffold(
        body: Center(child: Text('Terjadi kesalahan: $_errorMessage')),
      );
    if (_questions.isEmpty)
      return const Scaffold(
        body: Center(child: Text('Tidak ada soal tersedia.')),
      );

    final currentQuestion = _questions[_currentIndex];

    // DECODE STRING JSON OPTIONS MENJADI LIST OBJEK FLUTTER
    final List<dynamic> options = currentQuestion['options'] is String
        ? jsonDecode(currentQuestion['options'])
        : currentQuestion['options'] ?? [];

    // Hitung persentase bar hijau Duolingo
    double progressValue = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$_topicTitle - Level ${widget.level}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: const CloseButton(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SOAL ${_currentIndex + 1} DARI ${_questions.length}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    currentQuestion['question_text'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final String label = option['label'] ?? '';
                        final String text = option['text'] ?? '';
                        bool isSelected = _selectedOption == label;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          key: ValueKey(label),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(18),
                              backgroundColor: isSelected
                                  ? Colors.green[50]
                                  : Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedOption = label;
                              });
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$label. $text',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.green[800]
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                      backgroundColor: _selectedOption == null
                          ? Colors.grey[300]
                          : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _selectedOption == null ? null : _nextQuestion,
                    child: Text(
                      _currentIndex == _questions.length - 1
                          ? 'SELESAI'
                          : 'PERIKSA JAWABAN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedOption == null
                            ? Colors.grey[500]
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
