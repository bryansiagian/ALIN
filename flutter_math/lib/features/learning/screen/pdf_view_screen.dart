import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart'; // Memanggil API Client utama proyek Anda
import 'package:pdfrx/pdfrx.dart';

class PdfViewScreen extends ConsumerStatefulWidget {
  final String title;
  final String url;

  const PdfViewScreen({super.key, required this.title, required this.url});

  @override
  ConsumerState<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends ConsumerState<PdfViewScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Jalankan pengunduhan aliran langsung ke penyimpanan lokal disk ponsel
    Future.microtask(() => _downloadPdfToFile());
  }

  Future<void> _downloadPdfToFile() async {
    if (widget.url.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "URL PDF tidak valid";
      });
      return;
    }

    try {
      final String filename = widget.url.split('/').last;
      final tempDir = Directory.systemTemp;
      final String savePath = '${tempDir.path}/$filename';

      final apiClient = ref.read(apiClientProvider);

      // LANGSUNG TEMBAK URL ASLI (Sangat aman karena server sudah Multi-Threaded)
      await apiClient.dio.download(
        widget
            .url, // <--- Kembalikan menggunakan URL statis asli bawaan Laravel
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _localFilePath = savePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal mengunduh kepingan berkas materi: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Tampilan Loading Indikator Persentase Unduhan Real-Time
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.indigo,
              value: _downloadProgress > 0 ? _downloadProgress : null,
            ),
            const SizedBox(height: 16),
            Text(
              "Mengunduh segmen materi... ${(_downloadProgress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Tampilan penanganan jika koneksi terputus
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                    _downloadProgress = 0.0;
                  });
                  _downloadPdfToFile();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  "Coba Lagi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. BUKA SEARA INSTAN DARI BERKAS YANG SUDAH MATANG DI DISK PONSEL
    return PdfViewer.file(_localFilePath!);
  }
}
