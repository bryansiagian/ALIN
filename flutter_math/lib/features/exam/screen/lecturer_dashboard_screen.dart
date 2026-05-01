import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/exam/screen/create_assignment_screen.dart';
import 'package:flutter_math/features/exam/screen/assignment_questions_screen.dart';

class LecturerDashboardScreen extends ConsumerWidget {
  const LecturerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau daftar kuis secara reaktif
    final assignmentsAsync = ref.watch(myAssignmentsProvider);
    final lecturerService = LecturerService(ref.watch(apiClientProvider).dio);

    return Scaffold(
      // AppBar sudah dihandle oleh MainLecturerScreen, jika tidak pakai MainLecturerScreen, silakan aktifkan AppBar di sini.
      body: assignmentsAsync.when(
        data: (assignments) => RefreshIndicator(
          onRefresh: () => ref.refresh(myAssignmentsProvider.future),
          child: assignments.isEmpty
              ? const Center(child: Text("Belum ada kuis yang dibuat."))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final task = assignments[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          task.isSafeExam ? Icons.security : Icons.assignment,
                          color: task.isSafeExam ? Colors.red : Colors.blue,
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Deadline: ${task.deadline}"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'results') _showResults(context, ref, lecturerService, task.id);
                            if (val == 'questions') {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (c) => AssignmentQuestionsScreen(assignmentId: task.id, title: task.title)
                              ));
                            }
                          },
                          itemBuilder: (c) => [
                            const PopupMenuItem(value: 'results', child: Text("Lihat Hasil & Skor")),
                            const PopupMenuItem(value: 'questions', child: Text("Lihat Soal")),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateAssignmentScreen())),
        label: const Text("Buat Kuis SEB"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showResults(BuildContext context, WidgetRef ref, LecturerService service, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daftar Mahasiswa Terdaftar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: FutureBuilder(
                future: service.getAssignmentResults(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final data = snapshot.data as List? ?? [];

                  if (data.isEmpty) return const Center(child: Text("Belum ada mahasiswa."));

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final studentGroup = data[i];
                      final user = studentGroup['user'];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Terbaik: ${studentGroup['highest_score']} | ${studentGroup['total_attempts']} Percobaan"),
                          trailing: const Icon(Icons.chevron_right),
                          // KLIK: Lihat riwayat percobaan mahasiswa ini
                          onTap: () => _showAttempts(context, studentGroup['attempts'], user['name']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttempts(BuildContext context, List attempts, String studentName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade100,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Riwayat: $studentName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: attempts.length,
                itemBuilder: (context, i) {
                  final session = attempts[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text("Percobaan Ke-${attempts.length - i}"),
                      subtitle: Text("Skor: ${session['total_score']} | Pelanggaran: ${session['violation_count']}"),
                      trailing: const Icon(Icons.list_alt, color: Colors.indigo),
                      // KLIK: Lihat detail jawaban untuk sesi ini
                      onTap: () => _showStudentAnswers(context, session['answers']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentAnswers(BuildContext context, List answers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detail Jawaban"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: answers.length,
            itemBuilder: (context, i) {
              final ans = answers[i];
              return ListTile(
                title: Text(ans['question']['question_text'] ?? "Soal"),
                subtitle: Text("Jawab: ${ans['user_answer']} | Kunci: ${ans['question']['correct_answer']}"),
                trailing: Icon(ans['is_correct'] == 1 ? Icons.check : Icons.close, 
                          color: ans['is_correct'] == 1 ? Colors.green : Colors.red),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }
}