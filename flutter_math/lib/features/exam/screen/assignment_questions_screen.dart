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
                      Text("Soal ${index + 1}:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 5),
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
}