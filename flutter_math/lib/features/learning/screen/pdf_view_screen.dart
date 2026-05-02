import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const PdfViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    // Validasi sederhana biar nggak crash kalau URL kosong
    if (url.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("URL PDF tidak valid"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: PdfViewer.uri(
        Uri.parse(url),
        params: PdfViewerParams(
          loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: totalBytes != null
                        ? bytesDownloaded / totalBytes
                        : null,
                  ),
                  const SizedBox(height: 10),
                  const Text("Mengunduh Materi PDF..."),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}