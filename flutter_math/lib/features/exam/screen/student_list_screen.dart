import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/models/user_model.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = LecturerService(ref.watch(apiClientProvider).dio);

    return Scaffold(
      body: FutureBuilder<List<UserModel>>(
        future: service.getAllStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(student.name),
                subtitle: Text("${student.nim ?? '-'} | ${student.prodi ?? '-'}"),
                trailing: const Icon(Icons.analytics_outlined),
                onTap: () {
                  // Nanti di sini arahkan ke detail mahasiswa
                  _showStudentDetail(context, student.id, service);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showStudentDetail(BuildContext context, int id, LecturerService service) {
    // Implementasi Modal Detail Mahasiswa
    showModalBottomSheet(
      context: context,
      builder: (context) => FutureBuilder<Map<String, dynamic>>(
        future: service.getStudentDetail(id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(data['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                const Text("Progres Belajar:"),
                // Render progress topics...
              ],
            ),
          );
        },
      ),
    );
  }
}