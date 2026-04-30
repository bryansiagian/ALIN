class MaterialModel {
  final int id;
  final String title;
  final String content;
  final String contentType; // text, formula, animation

  MaterialModel({required this.id, required this.title, required this.content, required this.contentType});

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    contentType: json['content_type'],
  );
}