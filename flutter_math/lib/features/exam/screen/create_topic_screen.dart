import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';

class CreateTopicScreen extends ConsumerStatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  ConsumerState<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends ConsumerState<CreateTopicScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  void _submit() async {
    if (_titleController.text.isEmpty) return;

    try {
      // Kita pakai provider yang sudah ada di lecturer_service
      final service = ref.read(lecturerServiceProvider);
      await service.createTopic(
        title: _titleController.text,
        description: _descController.text,
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Balik dan kasih sinyal sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Topik Berhasil Dibuat!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Topik")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Nama Topik (Contoh: Eigenvalue)")),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Deskripsi Singkat")),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Simpan Topik"),
            )
          ],
        ),
      ),
    );
  }
}