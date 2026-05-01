import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';

class CreateQuestionScreen extends ConsumerStatefulWidget {
  final int topicId;
  const CreateQuestionScreen({super.key, required this.topicId});

  @override
  ConsumerState<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends ConsumerState<CreateQuestionScreen> {
  final _questionController = TextEditingController();
  final _optA = TextEditingController();
  final _optB = TextEditingController();
  final _optC = TextEditingController();
  final _optD = TextEditingController();
  String _correctKey = 'A';
  String _difficulty = 'medium';

  void _saveQuestion() async {
    final service = LecturerService(ref.read(apiClientProvider).dio);
    
    final data = {
      'topic_id': widget.topicId,
      'question_text': _questionController.text,
      'question_type': 'multiple_choice',
      'difficulty': _difficulty,
      'options': [
        {'key': 'A', 'text': _optA.text},
        {'key': 'B', 'text': _optB.text},
        {'key': 'C', 'text': _optC.text},
        {'key': 'D', 'text': _optD.text},
      ],
      'correct_answer': _correctKey,
      'explanation': 'Disusun oleh Dosen',
    };

    try {
      await service.createNewQuestion(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Soal Berhasil Disimpan!")));
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error simpan soal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Soal Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _questionController, maxLines: 3, decoration: const InputDecoration(labelText: "Pertanyaan", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            _buildOptionField(_optA, "Pilihan A"),
            _buildOptionField(_optB, "Pilihan B"),
            _buildOptionField(_optC, "Pilihan C"),
            _buildOptionField(_optD, "Pilihan D"),
            const SizedBox(height: 20),
            DropdownButtonFormField(
              value: _correctKey,
              decoration: const InputDecoration(labelText: "Kunci Jawaban"),
              items: ['A', 'B', 'C', 'D'].map((e) => DropdownMenuItem(value: e, child: Text("Jawaban $e"))).toList(),
              onChanged: (val) => setState(() => _correctKey = val as String),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveQuestion,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.indigo),
              child: const Text("Simpan ke Bank Soal", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.abc))),
    );
  }
}