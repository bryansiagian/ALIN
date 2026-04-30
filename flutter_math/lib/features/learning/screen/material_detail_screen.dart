import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/widget/latex_renderer.dart';

class MaterialDetailScreen extends ConsumerWidget {
  final int topicId;
  final String topicTitle;

  const MaterialDetailScreen({super.key, required this.topicId, required this.topicTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider(topicId));

    return Scaffold(
      appBar: AppBar(title: Text(topicTitle)),
      body: materialsAsync.when(
        data: (materials) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    // Logika Render berdasarkan content_type
                    if (material.contentType == 'formula')
                      Center(child: LatexRenderer(latex: material.content, fontSize: 24))
                    else
                      Text(material.content, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Gagal memuat materi: $err")),
      ),
    );
  }
}