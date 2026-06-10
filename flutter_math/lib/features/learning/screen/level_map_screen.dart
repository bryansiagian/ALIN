import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/sub_level_map_screen.dart';

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil data topik dan level absolut mahasiswa dari sensor Riverpod
    final topicsAsyncValue = ref.watch(topicsProvider);
    final progressAsyncValue = ref.watch(progressIndexProvider);
    final unlockedLevelAsyncValue = ref.watch(unlockedLevelProvider);

    final int userProgressIndex = ref.watch(
      progressIndexProvider,
    ); 
    final int actualUserLevel = ref.watch(
      unlockedLevelProvider,
    ); 

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Perjalanan Aljabar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // MEMINDAHKAN ANGKA LEVEL KE HEADER UTAMA (UX WIN)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: Colors.green[100],
              label: Text(
                'LV $actualUserLevel',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: topicsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Gagal memuat daftar bab: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (topics) {
          // Sterilisasi: Buang ID 6 (Placement Test) dari daftar folder belajar
          final learningTopics = topics.where((t) => t.id != 6).toList();

          if (learningTopics.isEmpty) {
            return const Center(child: Text('Belum ada materi pelajaran.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: learningTopics.length,
            itemBuilder: (context, index) {
              final topic = learningTopics[index];

              // Gembok bab besar terkunci jika urutan indeksnya melampaui progres mahasiswa
              bool isLocked = topic.orderIndex > userProgressIndex;

              return Card(
                elevation: isLocked ? 0 : 2,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isLocked ? Colors.grey[300]! : Colors.transparent,
                  ),
                ),
                color: isLocked ? Colors.grey[100] : Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: isLocked ? Colors.grey[400] : Colors.green,
                    child: isLocked
                        ? const Icon(Icons.lock, color: Colors.white)
                        : Text(
                            '${topic.orderIndex}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  title: Text(
                    topic.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isLocked ? Colors.grey[600] : Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      isLocked
                          ? 'Selesaikan bab sebelumnya untuk membuka'
                          : 'Ketuk untuk masuk ke peta level kuis',
                      style: TextStyle(
                        color: isLocked ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: isLocked ? Colors.grey[400] : Colors.green,
                    size: 18,
                  ),
                  onTap: () {
                    if (!isLocked) {
                      // NAVIGASI MASUK KE SUB-SCREEN LEVEL (MANDAT DUA TINGKAT)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubLevelMapScreen(
                            topicTitle: topic.title,
                            topicOrderIndex: topic.orderIndex,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Bab ini masih terkunci! Selesaikan materi sebelumnya.",
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
