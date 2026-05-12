import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/exam/guard/violation_reporter.dart';

// ─────────────────────────────────────────────
//  Provider
// ─────────────────────────────────────────────
final violationReporterProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ViolationReporter(dio);
});

// ─────────────────────────────────────────────
//  SEBGuard — class biasa (bukan StateNotifier)
//  karena dipakai manual, bukan lewat Riverpod provider
// ─────────────────────────────────────────────
class SEBGuard with WidgetsBindingObserver {
  final ViolationReporter _reporter;
  final int sessionId;

  /// Dipanggil saat pelanggaran pertama terdeteksi.
  /// Backend sudah auto-submit skor 0 — Flutter cukup navigasi ke hasil.
  final VoidCallback onViolation;

  bool _hasViolated = false;       // Cukup 1x, tidak perlu counter
  bool _isReporting = false;       // Mencegah laporan ganda
  DateTime? _lastViolationTime;    // Cooldown agar tidak double-trigger
  Timer? _cooldownTimer;

  static const _cooldownDuration = Duration(seconds: 3);

  SEBGuard(this._reporter, {required this.sessionId, required this.onViolation}) {
    WidgetsBinding.instance.addObserver(this);
    _enableProtections();
  }

  // ── Aktifkan proteksi layar ──
  Future<void> _enableProtections() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {
      // Tidak crash jika perangkat tidak mendukung
    }
  }

  // ── Matikan proteksi saat selesai ujian ──
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _cooldownTimer?.cancel();
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (_) {}
  }

  // ── Deteksi pindah app / notifikasi / home ──
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_hasViolated) return; // Sudah melanggar, tidak perlu laporan lagi

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _triggerViolationWithCooldown();
    }
  }

  // ── Cooldown: abaikan jika pelanggaran baru saja dilaporkan ──
  void _triggerViolationWithCooldown() {
    final now = DateTime.now();
    if (_lastViolationTime != null &&
        now.difference(_lastViolationTime!) < _cooldownDuration) {
      return; // Masih dalam cooldown, abaikan
    }
    _lastViolationTime = now;
    _triggerViolation();
  }

  Future<void> _triggerViolation() async {
    if (_isReporting || _hasViolated) return;
    _isReporting = true;

    try {
      final result = await _reporter.report(sessionId);
      final isLocked = result['is_locked'] ?? false;

      if (isLocked) {
        _hasViolated = true;
        // Backend sudah simpan skor 0 — panggil callback agar Flutter
        // navigasi ke ExamResultScreen dengan skor 0
        onViolation();
      }
    } catch (_) {
      // Gagal lapor: tidak crash, coba lagi pada trigger berikutnya
    } finally {
      _isReporting = false;
    }
  }

  bool get hasViolated => _hasViolated;
}