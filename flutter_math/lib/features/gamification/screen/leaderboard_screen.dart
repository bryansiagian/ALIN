import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/gamification/provider/gamification_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Papan Peringkat")),
      body: leaderboardAsync.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final entry = list[index];
            final isTopThree = index < 3;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isTopThree ? Colors.amber : Colors.grey[300],
                child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(entry.user?.name ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${entry.totalPoints} Poin"),
              trailing: isTopThree 
                ? const Icon(Icons.emoji_events, color: Colors.amber) 
                : null,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Gagal memuat peringkat")),
      ),
    );
  }
}