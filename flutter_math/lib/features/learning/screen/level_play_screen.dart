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

  void _loadQuestions() async {
    try {
      final repo = ref.read(levelRepositoryProvider);
      final data = await repo.getQuestionsByLevel(widget.level);
      if (mounted) {
        setState(() {
          _questions = data['questions'] ?? [];
          _topicTitle = data['topic_title'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _nextQuestion() {
    if (_selectedOption == null) return;

    _userAnswers.add({
      'question_id': _questions[_currentIndex]['id'],
      'selected_option': _selectedOption,
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      _submitQuiz();
    }
  }

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

  void _showResultDialog(Map<String, dynamic> result) {
    final bool isPassed = result['is_passed'] ?? false;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPassed
                        ? [Colors.white, Colors.green.shade50]
                        : [Colors.white, Colors.orange.shade50],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPassed
                          ? Icons.emoji_events
                          : Icons
                                .sentiment_very_dissatisfied, // Perbaikan: Huruf kecil
                      size: 80,
                      color: isPassed ? Colors.amber : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassed ? 'LEVEL SELESAI!' : 'COBA LAGI!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w900, // Perbaikan: Pakai w900 (Black)
                        color: isPassed
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result['message'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultStat(
                          'SKOR',
                          '${result['score']}%',
                          Colors.blue,
                        ),
                        _buildResultStat(
                          'BENAR',
                          '${result['correct_answers']}/5',
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPassed
                              ? Colors.green
                              : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          ref.invalidate(analyticsProvider);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'LANJUTKAN PERJALANAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900, // Perbaikan: Pakai w900
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.green, strokeWidth: 5),
        ),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text('Error: $_errorMessage')));
    }
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Tidak ada soal.')));
    }

    // Ganti logika pembacaan options dengan ini:
    // --- GANTI LOGIKA PEMBACAAN OPTIONS DENGAN INI ---
    final currentQuestion = _questions[_currentIndex];
    dynamic rawOptions = currentQuestion['options'];
    List<Map<String, dynamic>> options = [];

    try {
      dynamic parsedData = rawOptions;

      // 1. Jika berupa String, kita decode.
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
        // Jika ternyata masih berupa String (double-encoded), decode sekali lagi.
        if (parsedData is String) {
          parsedData = jsonDecode(parsedData);
        }
      }

      // 2. Petakan data ke dalam List yang dibutuhkan UI
      if (parsedData is Map) {
        options = parsedData.entries
            .map((e) => {'label': e.key.toString(), 'text': e.value.toString()})
            .toList();
      } else if (parsedData is List) {
        options = parsedData.map((item) {
          if (item is Map) {
            return {
              'label': (item['label'] ?? item['key'] ?? '').toString(),
              'text': (item['text'] ?? '').toString(),
            };
          }
          return <String, dynamic>{};
        }).toList();
      }
    } catch (e) {
      debugPrint("Error parsing options: $e");
      options = [];
    }
    // -------------------------------------------------

    double progressValue = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              _topicTitle.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Level ${widget.level}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const CloseButton(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 12,
                  width: MediaQuery.of(context).size.width * progressValue,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.green],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.2, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_currentIndex),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PERTANYAAN ${_currentIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentQuestion['question_text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3436),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ...options.map((option) {
                            final String label = option['label'] ?? '';
                            final String text = option['text'] ?? '';
                            bool isSelected = _selectedOption == label;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedOption = label),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.02 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green.shade50
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.green
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.green.shade900
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: _selectedOption == null
                            ? Colors.grey[300]
                            : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: _selectedOption == null ? 0 : 4,
                      ),
                      onPressed: _selectedOption == null ? null : _nextQuestion,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _questions.length - 1
                                ? 'SELESAIKAN LEVEL'
                                : 'CEK JAWABAN',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
