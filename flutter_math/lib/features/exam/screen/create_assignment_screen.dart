// lib/features/exam/screen/create_assignment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  ConsumerState<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends ConsumerState<CreateAssignmentScreen> {
  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController(
    text: DateTime.now().add(const Duration(days: 1)).toString(),
  );
  bool _isSafeExam = true;
  bool _allowReattempt = false;
  int _attemptLimit = 1;
  bool _showResults = true;


  // List untuk menampung soal-soal yang sedang diketik
  List<Map<String, dynamic>> _questions = [
    {
      'text': TextEditingController(),
      'a': TextEditingController(),
      'b': TextEditingController(),
      'c': TextEditingController(),
      'd': TextEditingController(),
      'key': 'A',
    },
  ];

  void _addQuestionField() {
    setState(() {
      _questions.add({
        'text': TextEditingController(),
        'a': TextEditingController(),
        'b': TextEditingController(),
        'c': TextEditingController(),
        'd': TextEditingController(),
        'key': 'A',
      });
    });
  }

  void _submitAll() async {
    // 1. Munculkan Loading
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));

    final service = LecturerService(ref.read(apiClientProvider).dio);
    
    List<Map<String, dynamic>> finalQuestions = _questions.map((q) => {
      'question_text': q['text'].text,
      'options': [
        {'key': 'A', 'text': q['a'].text},
        {'key': 'B', 'text': q['b'].text},
        {'key': 'C', 'text': q['c'].text},
        {'key': 'D', 'text': q['d'].text},
      ],
      'correct_answer': q['key'],
    }).toList();

    try {
      await service.createAssignment({
        'topic_id': 1,
        'title': _titleController.text,
        'deadline': _deadlineController.text,
        'duration_minutes': 60,
        'is_safe_exam': _isSafeExam,
        'questions': finalQuestions,
        // --- DATA BARU YANG DIKIRIM KE LARAVEL ---
        'allow_reattempt': _allowReattempt,
        'attempt_limit': _attemptLimit,
        'show_results': _showResults,
      });

      ref.invalidate(myAssignmentsProvider); 

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pop(context); // Balik ke dashboard
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kuis Berhasil Diterbitkan!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Kuis & Input Soal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BAGIAN 1: INFO KUIS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Judul Kuis",
                      ),
                    ),
                    SwitchListTile(
                      title: const Text("Mode SEB Aktif"),
                      value: _isSafeExam,
                      onChanged: (v) => setState(() => _isSafeExam = v),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                  title: const Text("Tampilkan Skor & Kunci"),
                  subtitle: const Text("Mahasiswa langsung melihat hasil setelah submit"),
                  value: _showResults,
                  onChanged: (v) => setState(() => _showResults = v),
                ),
                SwitchListTile(
                  title: const Text("Izinkan Mengulang (Re-attempt)"),
                  value: _allowReattempt,
                  onChanged: (v) => setState(() => _allowReattempt = v),
                ),
                if (_allowReattempt)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: const InputDecoration(labelText: "Batas Percobaan (Angka)"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _attemptLimit = int.tryParse(v) ?? 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BAGIAN 2: DAFTAR SOAL
            const Text(
              "Daftar Soal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._questions.asMap().entries.map((entry) {
              int idx = entry.key;
              var q = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text("Soal Nomor ${idx + 1}"),
                      TextField(
                        controller: q['text'],
                        decoration: const InputDecoration(
                          hintText: "Ketik Pertanyaan...",
                        ),
                      ),
                      TextField(
                        controller: q['a'],
                        decoration: const InputDecoration(prefixText: "A. "),
                      ),
                      TextField(
                        controller: q['b'],
                        decoration: const InputDecoration(prefixText: "B. "),
                      ),
                      TextField(
                        controller: q['c'],
                        decoration: const InputDecoration(prefixText: "C. "),
                      ),
                      TextField(
                        controller: q['d'],
                        decoration: const InputDecoration(prefixText: "D. "),
                      ),
                      DropdownButton<String>(
                        value: q['key'],
                        items: ['A', 'B', 'C', 'D']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text("Kunci: $e"),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => q['key'] = v!),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            TextButton.icon(
              onPressed: _addQuestionField,
              icon: const Icon(Icons.add),
              label: const Text("Tambah Soal Lagi"),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submitAll,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.indigo,
              ),
              child: const Text(
                "Terbitkan Kuis Sekarang",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
