class UserModel {
  final int id;
  final String name;
  final String? email;
  final String role;
  final String? avatar;
  final String? nim;
  final String? prodi;
  final String? nidn;
  final bool hasTakenPlacement;
  final int unlockedLevel; // ← DATA ADAPTIF BARU

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    this.avatar,
    this.nim,
    this.prodi,
    this.nidn,
    required this.hasTakenPlacement,
    required this.unlockedLevel, // ← BARU
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email']?.toString(),
      role: json['role'],
      avatar: json['avatar'],
      nim: json['nim'],
      prodi: json['prodi'],
      nidn: json['nidn'],
      hasTakenPlacement:
          json['has_taken_placement'] == true ||
          json['has_taken_placement'] == 1,
      unlockedLevel:
          json['unlocked_level'] ?? 1, // ← BARU (Default 1 jika null)
    );
  }
}
