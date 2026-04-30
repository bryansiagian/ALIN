import 'package:screen_protector/screen_protector.dart';
import 'package:safe_device/safe_device.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class SEBService {
  // 1. Aktifkan Proteksi Layar (Blokir Screenshot & Screen Recording)
  static Future<void> enableProtection() async {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.preventScreenshotOff(); // Untuk iOS biasanya butuh toggle
  }

  static Future<void> disableProtection() async {
    await ScreenProtector.preventScreenshotOff();
  }

  // 2. Cek apakah perangkat aman (Bukan Emulator & Tidak di-Root)
  static Future<bool> isDeviceSafe() async {
    if (kDebugMode) return true; // Beri pengecualian saat development

    bool isJailBroken = await SafeDevice.isJailBroken;
    bool isRealDevice = await SafeDevice.isRealDevice;
    
    return !isJailBroken && isRealDevice;
  }
}