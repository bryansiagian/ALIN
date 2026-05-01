import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';
import 'package:flutter_math/features/exam/screen/exam_result_screen.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Aktivitas"),
        actions: [
          // Tombol refresh manual di pojok kanan atas
          IconButton(
            onPressed: () => ref.invalidate(analyticsProvider),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: analyticsAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(analyticsProvider.future),
          child: ListView.builder(
            // Tambahkan AlwaysScrollable agar list bisa ditarik walau sedikit
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: data.sessions.length, // Sesuai debug tadi
            itemBuilder: (context, index) {
              final session = data.sessions[index];
              final assignment = session['assignment'];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(assignment['title'] ?? "Kuis"),
                  subtitle: Text("Skor: ${session['total_score']} | Percobaan Ke-${data.sessions.length - index}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _viewDetail(context, session, assignment),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  void _viewDetail(BuildContext context, dynamic session, dynamic assignment) {
    Map<int, String> userAnswers = {};
    final List answers = session['answers'] ?? [];
    for (var a in answers) {
      userAnswers[a['question_id']] = a['user_answer'];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamResultScreen(
          score: session['total_score'] ?? 0,
          questions: assignment['questions'] ?? [], 
          userAnswers: userAnswers,
          canShowDetail: true,
        ),
      ),
    );
  }
}