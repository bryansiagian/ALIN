import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/sub_level_map_screen.dart';

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsyncValue = ref.watch(topicsProvider);
    final int userProgressIndex = ref.watch(progressIndexProvider);
    final int actualUserLevel = ref.watch(unlockedLevelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Perjalanan Aljabar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LV $actualUserLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: topicsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Gagal memuat: $error')),
        data: (topics) {
          final learningTopics = topics.where((t) => t.id != 6).toList();
          if (learningTopics.isEmpty) {
            return const Center(child: Text('Belum ada materi pelajaran.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            itemCount: learningTopics.length,
            itemBuilder: (context, index) {
              final topic = learningTopics[index];
              bool isLocked = topic.orderIndex > userProgressIndex;
              bool isLast = index == learningTopics.length - 1;

              // Animasi Entrance
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(
                  milliseconds: 400 + (index * 100),
                ), // Efek berurutan
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sisi Kiri: Garis Titik-Titik dan Ikon Angka
                      Column(
                        children: [
                          _buildStepCircle(topic.orderIndex, isLocked),
                          if (!isLast)
                            Expanded(
                              child: CustomPaint(
                                size: const Size(2, double.infinity),
                                painter: DashedLinePainter(
                                  color: isLocked
                                      ? Colors.grey.shade400
                                      : Colors.green.shade400,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Sisi Kanan: Kartu Materi
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 30,
                          ), // Spasi antar level
                          child: _buildTopicCard(context, topic, isLocked),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget untuk Lingkaran Angka Level
  Widget _buildStepCircle(int order, bool isLocked) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked ? Colors.grey[300] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isLocked
                ? Colors.transparent
                : Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLocked ? Colors.grey[400]! : Colors.green,
          width: 3,
        ),
      ),
      child: Center(
        child: isLocked
            ? Icon(Icons.lock_rounded, size: 20, color: Colors.grey[600])
            : Text(
                '$order',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
      ),
    );
  }

  // Widget untuk Kartu Materi
  Widget _buildTopicCard(BuildContext context, dynamic topic, bool isLocked) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
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
          _showLockedSnackbar(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.white.withOpacity(0.6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey[500] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLocked
                        ? 'Selesaikan materi sebelumnya'
                        : 'Ketuk untuk belajar',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isLocked ? Colors.grey[400] : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Bab ini masih terkunci! 🔒"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

// Painter Khusus untuk Garis Titik-Titik
class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 5, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
