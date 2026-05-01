import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/forum/service/forum_service.dart';

class ForumFeedScreen extends ConsumerWidget {
  const ForumFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsProvider);

    return Scaffold(
      body: threadsAsync.when(
        data: (threads) => RefreshIndicator(
          onRefresh: () => ref.refresh(threadsProvider.future),
          child: ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final post = threads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(child: Text(post.user.name[0])),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(post.user.nim ?? post.user.role, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(post.body, style: const TextStyle(fontSize: 15)),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text("${post.repliesCount} Balasan", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostModal(context, ref),
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showCreatePostModal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Apa yang ingin Anda sampaikan?", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "Ketik di sini..."),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await ref.read(forumServiceProvider).postThread(
                  body: controller.text, // Cukup kirim body saja, title akan otomatis diurus service
                );
                ref.invalidate(threadsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Posting"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}