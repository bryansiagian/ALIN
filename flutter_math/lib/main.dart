import 'package:flutter_math/core/router.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    // ProviderScope wajib untuk Riverpod
    const ProviderScope(child: AlinApp()),
  );
}

class AlinApp extends ConsumerStatefulWidget {
  const AlinApp({super.key});

  @override
  ConsumerState<AlinApp> createState() => _AlinAppState();
}

class _AlinAppState extends ConsumerState<AlinApp> {
  @override
  void initState() {
    super.initState();
    // Cek status login saat aplikasi pertama kali dijalankan
    Future.microtask(() => ref.read(authProvider.notifier).checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ALIN - Aljabar Linear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo, // Tema warna Aljabar (Profesional)
        textTheme: GoogleFonts.poppinsTextTheme(), // Font modern
      ),
      routerConfig: router,
    );
  }
}
