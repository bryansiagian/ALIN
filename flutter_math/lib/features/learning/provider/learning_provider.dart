import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/learning/service/learning_service.dart';
import 'package:flutter_math/features/learning/model/topic_model.dart';
import 'package:flutter_math/features/learning/model/material_model.dart';
import 'package:flutter_math/features/learning/model/formula_model.dart';

final learningServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return LearningService(dio);
});

// Provider untuk daftar Topik
final topicsProvider = FutureProvider<List<TopicModel>>((ref) async {
  return ref.watch(learningServiceProvider).getTopics();
});

// Provider untuk daftar Materi berdasarkan Topic ID
final materialsProvider = FutureProvider.family<List<MaterialModel>, int>((ref, topicId) async {
  return ref.watch(learningServiceProvider).getMaterials(topicId);
});

// Provider untuk daftar Rumus (Cheat Sheet)
final formulasProvider = FutureProvider<List<FormulaModel>>((ref) async {
  return ref.watch(learningServiceProvider).getFormulas();
});

// Pipa 3: Mengambil angka progress level mahasiswa langsung dari sensor Laravel
final progressIndexProvider = FutureProvider<int>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    // Mengetuk pintu api/analytics
    final response = await apiClient.dio.get('analytics');

    // Ambil nilai dari laci 'user_progress_index', jika kosong berikan angka 1
    return response.data['user_progress_index'] ?? 1;
  } catch (e) {
    // Jika koneksi putus atau error, kembalikan level 1 demi keamanan sistem
    return 1;
  }
});
