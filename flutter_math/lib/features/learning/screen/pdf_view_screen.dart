import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
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

  // Variabel untuk indikator halaman (Opsional, untuk mempercantik tampilan)
  int _totalPages = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
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

      await apiClient.dio.download(
        widget.url,
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
      backgroundColor: const Color(0xFFF5F7FA), // Warna latar belakang modern
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      // Gunakan AnimatedSwitcher agar transisi dari loading ke PDF terasa halus/smooth
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Tampilan Loading Indikator (Dibuat Modern dalam Card)
    if (_isLoading) {
      return Center(
        key: const ValueKey('loading'),
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.indigo,
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 5,
              ),
              const SizedBox(height: 24),
              Text(
                "Mengunduh Materi...",
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Tampilan Error (Dibuat Clean dengan Ikon Besar)
    if (_errorMessage != null) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Tampilan PDF Viewer (Ditambahkan Page Indicator Overlay)
    return Stack(
      key: const ValueKey('pdf_view'),
      children: [
        PdfViewer.file(
          _localFilePath!,
          params: PdfViewerParams(
            onViewerReady: (document, controller) {
              setState(() => _totalPages = document.pages.length);
            },
            onPageChanged: (pageNumber) {
              setState(() => _currentPage = pageNumber ?? 1);
            },
          ),
        ),
        // Page Indicator Floating (Menandakan Aplikasi Premium)
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade900.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Text(
                "$_currentPage / $_totalPages",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
