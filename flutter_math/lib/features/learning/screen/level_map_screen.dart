/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/level_play_screen.dart';

class LevelMapScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Membuka keran daftar topik materi
    final topicsAsyncValue = ref.watch(topicsProvider);

    // 2. Membuka keran nomor progress level mahasiswa secara dinamis!
    final progressAsyncValue = ref.watch(progressIndexProvider);

    // Ambil angkanya, jika data belum sampai dari internet, anggap sementara level 1
    final int userProgressIndex = progressAsyncValue.value ?? 1;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: Text('Perjalanan Aljabar')),
      body: topicsAsyncValue.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Gagal memuat peta: $error',
            style: TextStyle(color: Colors.red),
          ),
        ),
        data: (topics) {
          if (topics.isEmpty) {
            return Center(child: Text('Belum ada materi pelajaran.'));
          }

          return ListView.builder(
            reverse: true, // Jalan setapak dimulai dari bawah layar
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];

              bool isLocked = topic.orderIndex > userProgressIndex;

              // Zig-Zag: Genap di kiri, Ganjil di kanan
              bool isLeftAligned = index % 2 == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Align(
                  alignment: isLeftAligned
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!isLocked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Membuka materi: ${topic.title}",
                                  ),
                                ),
                              );
                              // TODO: Navigasi ke material_detail_screen.dart
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Topik ini masih terkunci!"),
                                ),
                              );
                            }
                          },
                          // --- DI SINI PERUBAHAN BERSIHNYA ---
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: isLocked
                                ? Colors.grey
                                : Colors.green,
                            child:
                                isLocked // Kunci "child:" wajib ada di sini!
                                ? Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 35,
                                  )
                                : Text(
                                    '${topic.orderIndex}', // Menampilkan nomor level
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          // ----------------------------------
                        ),
                        SizedBox(height: 8),
                        Text(
                          topic.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/level_play_screen.dart';

class LevelMapScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Membuka keran daftar topik materi
    final topicsAsyncValue = ref.watch(topicsProvider);

    // 2. Membuka keran nomor progress level mahasiswa secara dinamis!
    final progressAsyncValue = ref.watch(progressIndexProvider);

    // Ambil angkanya, jika data belum sampai dari internet, anggap sementara level 1
    final int userProgressIndex = progressAsyncValue.value ?? 1;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: Text('Perjalanan Aljabar')),
      body: topicsAsyncValue.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Gagal memuat peta: $error',
            style: TextStyle(color: Colors.red),
          ),
        ),
        data: (topics) {
          if (topics.isEmpty) {
            return Center(child: Text('Belum ada materi pelajaran.'));
          }

          return ListView.builder(
            reverse: true, // Jalan setapak dimulai dari bawah layar
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];

              bool isLocked = topic.orderIndex > userProgressIndex;

              // Zig-Zag: Genap di kiri, Ganjil di kanan
              bool isLeftAligned = index % 2 == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Align(
                  alignment: isLeftAligned
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!isLocked) {
                              // MANDAT: Pindah ke halaman LevelPlayScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Kita tembak ke Level 5 dulu untuk uji coba data donat Matriks Dasar Anda
                                  builder: (context) =>
                                      const LevelPlayScreen(level: 5),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Topik ini masih terkunci!"),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: isLocked
                                ? Colors.grey
                                : Colors.green,
                            child: isLocked
                                ? const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 35,
                                  )
                                : Text(
                                    '${topic.orderIndex}', // Menampilkan nomor level/stasiun
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          topic.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
