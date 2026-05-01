import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/exam_service.dart';
import 'package:flutter_math/models/assignment_model.dart';
import 'package:flutter_math/features/exam/screen/exam_screen.dart';

class AssignmentListScreen extends ConsumerWidget {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examService = ref.watch(examServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tugas & Kuis")),
      body: FutureBuilder( 
        future: examService.getAssignments(), // Biarkan Flutter mendeteksi tipenya sendiri
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          final assignments = snapshot.data ?? [];
          if (assignments.isEmpty) return const Center(child: Text("Tidak ada kuis aktif."));

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final item = assignments[index];
              final int sisa = item.attemptLimit - item.examSessionsCount;
              final bool canAttempt = sisa > 0;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(item.isSafeExam ? Icons.lock : Icons.assignment, 
                           color: item.isSafeExam ? Colors.red : Colors.indigo),
                  title: Text(item.title),
                  subtitle: Text("Sisa Percobaan: $sisa kali"), // Info buat mahasiswa
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAttempt ? Colors.indigo : Colors.grey,
                    ),
                    // Jika jatah habis, tombol otomatis tidak bisa diklik (null)
                    onPressed: canAttempt ? () => _startExam(context, ref, item) : null,
                    child: Text(canAttempt ? "Kerjakan" : "Selesai"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _startExam(BuildContext context, WidgetRef ref, AssignmentModel assignment) async {
      try {
        final response = await ref.read(examServiceProvider).startExam(assignment.id);
        
        final int sessionId = response['session']['id'];
        final List questions = response['questions'];
        // AMBIL NILAI DARI RESPONSE API
        final bool showResults = response['assignment']['show_results'] == 1 || 
                                response['assignment']['show_results'] == true;

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamScreen(
                sessionId: sessionId,
                questions: questions,
                duration: assignment.durationMinutes,
                showResults: showResults, // KIRIM KE EXAM SCREEN
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
  }
}