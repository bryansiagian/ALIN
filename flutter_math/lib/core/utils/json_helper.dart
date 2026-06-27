import 'dart:convert';

class JsonHelper {
  static List<Map<String, dynamic>> parseOptions(dynamic options) {
    if (options is List) {
      return List<Map<String, dynamic>>.from(options);
    } else if (options is String) {
      try {
        final decoded = jsonDecode(options);
        if (decoded is Map) {
          // Mengubah {"A": "teks", "B": "teks"} menjadi List
          return decoded.entries
              .map((e) => {'label': e.key, 'text': e.value.toString()})
              .toList();
        }
        return List<Map<String, dynamic>>.from(decoded);
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
