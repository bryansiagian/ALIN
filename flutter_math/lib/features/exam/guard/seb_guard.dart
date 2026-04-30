import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/exam/guard/violation_reporter.dart';

// --- Provider ---
final violationReporterProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ViolationReporter(dio);
});

// --- State Class ---
class SEBState {
  final int violationCount;
  final bool isLocked;
  final String? lastErrorMessage;

  SEBState({this.violationCount = 0, this.isLocked = false, this.lastErrorMessage});

  SEBState copyWith({int? violationCount, bool? isLocked, String? lastErrorMessage}) {
    return SEBState(
      violationCount: violationCount ?? this.violationCount,
      isLocked: isLocked ?? this.isLocked,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }
}

// --- Notifier ---
class SEBGuard extends StateNotifier<SEBState> with WidgetsBindingObserver {
  final ViolationReporter _reporter;
  final int sessionId;
  final VoidCallback onLocked; 

  SEBGuard(this._reporter, {required this.sessionId, required this.onLocked}) : super(SEBState()) {
    WidgetsBinding.instance.addObserver(this);
    _enableProtections();
  }

  /// Aktifkan proteksi sistem. 
  /// Di Android, preventScreenshotOn otomatis memblokir Screen Recording (Layar Hitam).
  Future<void> _enableProtections() async {
    await ScreenProtector.preventScreenshotOn();
  }

  /// Matikan proteksi saat keluar ujian
  Future<void> disableProtections() async {
    WidgetsBinding.instance.removeObserver(this);
    await ScreenProtector.preventScreenshotOff();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Deteksi jika user pindah aplikasi, buka notifikasi, atau tekan tombol Home
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _triggerViolation();
    }
  }

  Future<void> _triggerViolation() async {
    try {
      final result = await _reporter.report(sessionId);
      
      state = state.copyWith(
        violationCount: result['violation_count'],
        isLocked: result['is_locked'],
      );

      if (state.isLocked) {
        onLocked(); 
      }
    } catch (e) {
      state = state.copyWith(lastErrorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    disableProtections();
    super.dispose();
  }
}