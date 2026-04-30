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
    final lecturerService = LecturerService(ref.watch(apiClientProvider).dio);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Dosen ALIN"),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder(
        future: lecturerService.getMyAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          final assignments = snapshot.data ?? [];

          if (assignments.isEmpty) {
            return const Center(child: Text("Belum ada kuis yang dibuat."));
          }

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final task = assignments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => _showResults(context, lecturerService, task.id),
                  leading: Icon(
                    task.isSafeExam ? Icons.security : Icons.assignment,
                    color: task.isSafeExam ? Colors.red : Colors.blue,
                  ),
                  title: Text(task.title),
                  subtitle: Text("Deadline: ${task.deadline}"),
                  // GANTI ICON TRAILING MENJADI TOMBOL MENU
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'results') {
                        _showResults(context, lecturerService, task.id);
                      } else if (value == 'questions') {
                        // NAVIGASI KE HALAMAN SOAL
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignmentQuestionsScreen(
                              assignmentId: task.id,
                              title: task.title,
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'results',
                        child: Text("Lihat Hasil"),
                      ),
                      const PopupMenuItem(
                        value: 'questions',
                        child: Text("Lihat Soal"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateAssignmentScreen(),
          ),
        ),
        label: const Text("Buat Kuis SEB"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  // --- FUNGSI UNTUK MONITORING HASIL UJIAN MAHASISWA ---
  void _showResults(BuildContext context, LecturerService service, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monitoring Peserta Ujian",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Dosen dapat melihat pelanggaran SEB secara real-time",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder(
                future: service.getAssignmentResults(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final results = snapshot.data as List? ?? [];

                  if (results.isEmpty) {
                    return const Center(
                      child: Text("Belum ada mahasiswa yang mengerjakan."),
                    );
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final res = results[i];
                      final violationCount = res['violation_count'] ?? 0;
                      final isLocked =
                          res['is_locked'] == 1 || res['is_locked'] == true;

                      return Card(
                        color: isLocked ? Colors.red.shade50 : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isLocked
                                ? Colors.red
                                : Colors.indigo,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(res['user']['name'] ?? "Mahasiswa"),
                          subtitle: Text("Pelanggaran: $violationCount kali"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Skor: ${res['total_score'] ?? '-'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isLocked)
                                const Icon(
                                  Icons.block,
                                  color: Colors.red,
                                  size: 16,
                                ),
                            ],
                          ),
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
}
