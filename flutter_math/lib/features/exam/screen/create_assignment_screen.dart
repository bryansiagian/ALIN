import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  ConsumerState<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends ConsumerState<CreateAssignmentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _topicId = 1; // Default ke topik 1
  int _duration = 30;
  int _qCount = 5;
  bool _isSafeExam = false; // SWITCH UNTUK SEB

  void _submit() async {
    final service = LecturerService(ref.read(apiClientProvider).dio);
    await service.createAssignment({
      'topic_id': _topicId,
      'title': _titleController.text,
      'description': _descController.text,
      'deadline': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'duration_minutes': _duration,
      'question_count': _qCount,
      'is_safe_exam': _isSafeExam, // MENGIRIM STATUS SEB KE LARAVEL
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Tugas Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul Kuis")),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Aktifkan Mode SEB (Safe Exam Browser)"),
              subtitle: const Text("Mahasiswa tidak bisa screenshot atau pindah aplikasi"),
              value: _isSafeExam,
              onChanged: (val) => setState(() => _isSafeExam = val),
              secondary: const Icon(Icons.security, color: Colors.red),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Terbitkan Tugas"),
            )
          ],
        ),
      ),
    );
  }
}