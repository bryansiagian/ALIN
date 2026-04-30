import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/dashboard/provider/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Analitik Belajar")),
      body: analyticsAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ringkasan Progres & Streak
              Row(
                children: [
                  _buildStatCard("Streak", "${data.currentStreak} Hari", Icons.local_fire_department, Colors.orange),
                  const SizedBox(width: 10),
                  _buildStatCard("Selesai", "${data.completedTopics} Topik", Icons.check_circle, Colors.green),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Lingkaran Progres Keseluruhan
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 150, width: 150,
                          child: CircularProgressIndicator(
                            value: data.overallPercentage / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            color: Colors.indigo,
                          ),
                        ),
                        Text("${data.overallPercentage}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Total Penguasaan Materi", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text("Progres per Topik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // 3. List Progres Tiap Bab
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.topicAnalytics.length,
                itemBuilder: (context, index) {
                  final topic = data.topicAnalytics[index];
                  return Card(
                    child: ListTile(
                      title: Text(topic.topicTitle),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: topic.scoreAvg / 100),
                          Text("Rata-rata Nilai: ${topic.scoreAvg}"),
                        ],
                      ),
                      trailing: Text(topic.status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Gagal memuat analitik: $err")),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.black54)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}