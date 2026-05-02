import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/exam/screen/create_topic_screen.dart';

class UploadMaterialScreen extends ConsumerStatefulWidget {
  const UploadMaterialScreen({super.key});

  @override
  ConsumerState<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends ConsumerState<UploadMaterialScreen> {
  final _titleController = TextEditingController();
  int? _selectedTopicId;
  File? _selectedFile;
  List<dynamic> _topics = [];
  bool _isLoadingTopics = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final service = LecturerService(ref.read(apiClientProvider).dio);
      final data = await service.getTopicsList();
      setState(() {
        _topics = data;
        _isLoadingTopics = false;
      });
    } catch (e) {
      setState(() => _isLoadingTopics = false);
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null || _selectedTopicId == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi judul, topik, dan file PDF!")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = LecturerService(ref.read(apiClientProvider).dio);
      await service.uploadMaterial(
        topicId: _selectedTopicId!,
        title: _titleController.text,
        filePath: _selectedFile!.path,
      );
      
      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pop(context); // Kembali ke Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil mengunggah materi PDF!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengunggah: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Materi Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Judul Materi", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Contoh: Determinan Matriks Invers"),
            ),
            const SizedBox(height: 20),
            
            const Text("Pilih Topik", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: _isLoadingTopics
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<int>(
                        value: _selectedTopicId,
                        items: _topics.map((t) => DropdownMenuItem<int>(
                          value: t['id'], 
                          child: Text(t['title'])
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedTopicId = v),
                        decoration: const InputDecoration(hintText: "Pilih Bab"),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateTopicScreen()));
                    if (result == true) _loadTopics();
                  },
                )
              ],
            ),
            const SizedBox(height: 30),
            
            const Text("File Materi (PDF)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickPDF,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 50, color: _selectedFile == null ? Colors.grey : Colors.indigo),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFile == null 
                        ? "Klik untuk memilih file PDF" 
                        : "File Terpilih: ${_selectedFile!.path.split('/').last}",
                      style: TextStyle(color: _selectedFile == null ? Colors.grey : Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Upload Sekarang", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}