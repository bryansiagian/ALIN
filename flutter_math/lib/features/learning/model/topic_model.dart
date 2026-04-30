class TopicModel {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final int orderIndex;

  TopicModel({required this.id, required this.title, required this.slug, this.description, required this.orderIndex});

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json['id'],
    title: json['title'],
    slug: json['slug'],
    description: json['description'],
    orderIndex: json['order_index'],
  );
}