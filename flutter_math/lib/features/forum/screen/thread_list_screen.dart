import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/forum/provider/forum_provider.dart';

class ThreadListScreen extends ConsumerWidget {
  const ThreadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Forum Diskusi ALIN")),
      body: threadsAsync.when(
        data: (threads) => RefreshIndicator(
          onRefresh: () => ref.refresh(threadsProvider.future),
          child: ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(thread.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Oleh: ${thread.user.name} • ${thread.topicTitle}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigasi ke detail (jika sudah buat screen detailnya)
                  },
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Gagal memuat diskusi")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostModal(context, ref),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showCreatePostModal(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal tidak tertutup keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Geser ke atas jika keyboard muncul
          left: 20, 
          right: 20, 
          top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buat Diskusi Baru", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul Diskusi (Singkat)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Apa yang ingin Anda sampaikan?",
                hintText: "Contoh: Izin bertanya tentang matriks invers...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty || bodyController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Judul dan isi tidak boleh kosong!"))
                    );
                    return;
                  }

                  try {
                    // Kirim ke API Laravel
                    // Pastikan di forum_service.dart fungsi postThread menerima 2 parameter (title & body)
                    await ref.read(forumServiceProvider).postThread(
                      title: titleController.text,
                      body: bodyController.text,
                    );

                    // Refresh data agar postingan baru muncul
                    ref.invalidate(threadsProvider);

                    if (context.mounted) {
                      Navigator.pop(context); // Tutup modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Berhasil memposting diskusi!"))
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal: $e"))
                      );
                    }
                  }
                },
                child: const Text("Posting ke Forum", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}