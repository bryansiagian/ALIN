class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String iconKey; // Key untuk memanggil asset/icon di Flutter
  final String earnedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    iconKey: json['icon_key'],
    earnedAt: json['pivot'] != null ? json['pivot']['earned_at'] : '',
  );
}