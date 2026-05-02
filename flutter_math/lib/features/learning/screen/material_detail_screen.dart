import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/widget/latex_renderer.dart';
import 'package:flutter_math/features/learning/screen/pdf_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialDetailScreen extends ConsumerWidget {
  final int topicId;
  final String topicTitle;

  const MaterialDetailScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  Future<void> _downloadPDF(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka link download")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider(topicId));

    return Scaffold(
      appBar: AppBar(
        title: Text(topicTitle),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: materialsAsync.when(
        data: (materials) {
          if (materials.isEmpty) {
            return const Center(child: Text("Belum ada materi untuk topik ini."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              final bool isPdf = material.fileUrl != null;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              material.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isPdf)
                            const Icon(Icons.picture_as_pdf, color: Colors.red),
                        ],
                      ),
                      const Divider(),
                      if (isPdf) ...[
                        const Text("Format: Dokumen PDF"),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PdfViewScreen(
                                        title: material.title,
                                        url: material.fileUrl!,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.menu_book),
                                label: const Text("Baca"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _downloadPDF(context, material.fileUrl!),
                                icon: const Icon(Icons.download),
                                label: const Text("Download"),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.indigo),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        if (material.contentType == 'formula')
                          Center(
                              child: LatexRenderer(
                                  latex: material.content ?? "", fontSize: 24))
                        else
                          Text(material.content ?? "Tidak ada isi materi.",
                              style: const TextStyle(fontSize: 16)),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Gagal memuat materi: $err")),
      ),
    );
  }
}