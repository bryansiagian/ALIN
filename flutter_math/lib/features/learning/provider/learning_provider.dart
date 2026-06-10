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
final materialsProvider = FutureProvider.family<List<MaterialModel>, int>((
  ref,
  topicId,
) async {
  return ref.watch(learningServiceProvider).getMaterials(topicId);
});

// Provider untuk daftar Rumus (Cheat Sheet)
final formulasProvider = FutureProvider<List<FormulaModel>>((ref) async {
  return ref.watch(learningServiceProvider).getFormulas();
});

// =========================================================================
// PUSAT KENDALI UTAMA: Hanya provider ini yang berhak mengetuk pintu internet
// =========================================================================
final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('analytics');
  return response.data as Map<String, dynamic>;
});

// PROVIDER TURUNAN 1: Mengambil angka bab aktif (Mengikuti Pusat Kendali)
final progressIndexProvider = Provider<int>((ref) {
  final analyticsAsync = ref.watch(analyticsProvider);
  return analyticsAsync.maybeWhen(
    data: (data) => data['user_progress_index'] ?? 1,
    orElse: () => 1, // Nilai fallback aman jika sedang loading/error
  );
});

// PROVIDER TURUNAN 2: Mengambil angka level absolut (Mengikuti Pusat Kendali)
final unlockedLevelProvider = Provider<int>((ref) {
  final analyticsAsync = ref.watch(analyticsProvider);
  return analyticsAsync.maybeWhen(
    data: (data) => data['unlocked_level'] ?? 1,
    orElse: () => 1, // Nilai fallback aman jika sedang loading/error
  );
});
