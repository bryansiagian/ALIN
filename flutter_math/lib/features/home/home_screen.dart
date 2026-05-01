import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/material_detail_screen.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/screen/assignment_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil data topik dari Laravel via Riverpod
    final topicsAsync = ref.watch(topicsProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Materi ALIN"),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Selamat Datang
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Halo, ${user?.name ?? 'Mahasiswa'}!\nSiap belajar Aljabar hari ini?",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Pilih Topik Materi:", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Column(
              children: [
                const Text("Ada tugas untukmu!", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentListScreen())),
                  icon: const Icon(Icons.quiz),
                  label: const Text("Buka Daftar Ujian"),
                ),
              ],
            ),
          ),

          // 2. Tampilkan Daftar Topik
          Expanded(
            child: topicsAsync.when(
              data: (topics) => ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text("${topic.orderIndex}", style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(topic.description ?? ""),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigasi ke Detail Materi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MaterialDetailScreen(
                              topicId: topic.id,
                              topicTitle: topic.title,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Gagal mengambil data: $err")),
            ),
          ),
        ],
      ),
    );
  }
}