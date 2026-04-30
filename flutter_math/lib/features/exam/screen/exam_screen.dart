import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

// IMPORT INI YANG HILANG:
import 'package:flutter_math/features/exam/guard/seb_guard.dart'; 
// (Opsional) Jika ExamService dibutuhkan di sini:
import 'package:flutter_math/features/exam/service/exam_service.dart'; 

class ExamScreen extends ConsumerStatefulWidget {
  final int sessionId;
  const ExamScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  // SEBGuard sekarang akan dikenali setelah import di atas ditambahkan
  late SEBGuard _sebGuard;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi SEB Guard (Logika penguncian layar & deteksi pindah app)
    _sebGuard = SEBGuard(
      ref.read(violationReporterProvider),
      sessionId: widget.sessionId,
      onLocked: () {
        // Callback ini dipicu jika Laravel mengembalikan is_locked = true
        _handleLockedExam();
      },
    );
  }

  void _handleLockedExam() {
    // Memastikan dialog muncul meskipun user sedang tidak fokus
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa menutup dialog dengan klik luar
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 10),
            Text("Ujian Terkunci!"),
          ],
        ),
        content: const Text(
          "Anda terdeteksi melakukan pelanggaran (screenshot/pindah aplikasi) "
          "lebih dari batas yang ditentukan. Sesi ujian Anda telah dihentikan secara otomatis. "
          "Silakan hubungi dosen pengampu untuk pembukaan blokir.",
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Menghapus semua route dan kembali ke Dashboard
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Keluar dari Ujian", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Sangat Penting: Mematikan observer & proteksi screenshot saat keluar
    _sebGuard.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan WillPopScope (atau PopScope di Flutter terbaru) 
    // agar user tidak bisa keluar menggunakan tombol 'Back' HP
    return PopScope(
      canPop: false, // Mematikan tombol back hardware
      onPopInvoked: (didPop) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selesaikan ujian terlebih dahulu untuk keluar.")),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ALIN - Ujian Aman"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Menghapus tombol back di AppBar
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              Text(
                "Sesi Ujian: ${widget.sessionId}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                // Ganti Colors.amberContainer dengan ini:
                color: Colors.amber.shade100, 
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "PERINGATAN: Jangan menekan tombol Home, berpindah aplikasi, "
                    "atau melakukan screenshot. Sistem akan mendeteksi kecurangan secara otomatis.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(), // Placeholder untuk konten soal
              const SizedBox(height: 20),
              const Text("Memuat Soal Aljabar Linear..."),
            ],
          ),
        ),
      ),
    );
  }
}