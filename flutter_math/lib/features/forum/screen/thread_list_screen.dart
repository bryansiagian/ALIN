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
                    // Navigasi ke Detail (Gunakan GoRouter sesuai struktur Anda)
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
        onPressed: () {
          // Navigasi ke halaman buat thread baru
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}