import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';

class LecturerDashboardScreen extends ConsumerWidget {
  const LecturerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturerService = LecturerService(ref.watch(apiClientProvider).dio);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Dosen")),
      body: FutureBuilder(
        future: lecturerService.getMyAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

          final assignments = snapshot.data ?? [];
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final task = assignments[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text("Deadline: ${task.deadline}"),
                  trailing: const Icon(Icons.analytics),
                  onTap: () {
                    // Navigasi ke Monitoring Screen
                    _showResults(context, lecturerService, task.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Modal Monitoring Hasil ---
  void _showResults(BuildContext context, LecturerService service, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: service.getAssignmentResults(id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final results = snapshot.data as List;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final res = results[i];
                return ListTile(
                  title: Text(res['user']['name']),
                  subtitle: Text("Pelanggaran: ${res['violation_count']} kali"),
                  trailing: res['is_locked'] == 1 
                      ? const Icon(Icons.lock, color: Colors.red) 
                      : const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCreateForm(BuildContext context) {
    // Di sini Anda bisa memanggil Screen Form Buat Tugas Baru
    print("Membuka form buat tugas...");
  }
}