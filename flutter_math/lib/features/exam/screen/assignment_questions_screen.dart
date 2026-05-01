import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';

class AssignmentQuestionsScreen extends ConsumerWidget {
  final int assignmentId;
  final String title;

  const AssignmentQuestionsScreen({super.key, required this.assignmentId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturerService = LecturerService(ref.watch(apiClientProvider).dio);

    return Scaffold(
      appBar: AppBar(title: Text("Soal: $title")),
      body: FutureBuilder(
        future: lecturerService.getAssignmentQuestions(assignmentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final questions = snapshot.data as List;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Soal ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                            onPressed: () => _showEditDialog(context, ref, q), // Panggil dialog edit
                          ),
                        ],
                      ),
                      Text(q['question_text']),
                      const Divider(),
                      // Tampilkan pilihan jawaban
                      if (q['options'] != null)
                        ...(q['options'] as List).map((opt) => Text("${opt['key']}. ${opt['text']}")).toList(),
                      const SizedBox(height: 10),
                      Text("Jawaban Benar: ${q['correct_answer']}", 
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Map q) {
    final controller = TextEditingController(text: q['question_text']);
    String correctKey = q['correct_answer'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Soal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(labelText: "Teks Soal")),
            DropdownButton<String>(
              value: correctKey,
              items: ['A','B','C','D'].map((e) => DropdownMenuItem(value: e, child: Text("Kunci: $e"))).toList(),
              onChanged: (v) => correctKey = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await ref.read(lecturerServiceProvider).updateQuestion(q['id'], {
                'question_text': controller.text,
                'correct_answer': correctKey,
              });

              // CEK MOUNTED
              if (!context.mounted) return;

              Navigator.pop(context); // Tutup Dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Soal berhasil diperbarui!")),
              );
            },
            child: const Text("Simpan")
          ),
        ],
      ),
    );
  }
}