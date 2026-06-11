import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/placement/service/placement_service.dart';
import 'package:flutter_math/core/api/api_client.dart';      
import 'package:flutter_math/core/api/api_endpoints.dart';   

// ─── Service Provider ──────────────────────────────────────────────────────

final placementServiceProvider = Provider<PlacementService>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return PlacementService(dio);
});

// ─── Questions Provider (FutureProvider) ──────────────────────────────────
// Dipakai oleh PlacementScreen untuk fetch soal.

final placementProvider =
    AsyncNotifierProvider<PlacementNotifier, List<Map<String, dynamic>>>(
  PlacementNotifier.new,
);

class PlacementNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final service = ref.watch(placementServiceProvider);
    return service.getQuestions();
  }

    Future<Map<String, dynamic>> submitPlacement(List<Map<String, dynamic>> answers) async {
    try {
      // --- PERBAIKAN MUTLAK: Membaca ApiClient langsung menggunakan sensor ref Riverpod ---
      final response = await ref.read(apiClientProvider).dio.post(
        ApiEndpoints.placementSubmit,
        data: {
          'answers': answers,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal mengirimkan jawaban placement: $e');
    }
  }
}

// ─── Result Provider (FutureProvider) ─────────────────────────────────────
// Dipakai jika ingin menampilkan hasil placement di halaman profil.

final placementResultProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(placementServiceProvider);
  return service.getResult();
});