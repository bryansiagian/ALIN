class MaterialModel {
  final int id;
  final String title;
  final String? content;      // Tambahkan kembali ini
  final String? contentType;  // Tambahkan kembali ini (formula, text, dll)
  final String? fileUrl;      // Ini untuk PDF

  MaterialModel({
    required this.id,
    required this.title,
    this.content,
    this.contentType,
    this.fileUrl,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      title: json['title'] ?? "",
      content: json['content'],
      contentType: json['content_type'],
      // Ambil file_url dari accessor Laravel 'getFileUrlAttribute'
      fileUrl: json['file_url'], 
    );
  }
}