class UserModel {
  final int id;
  final String name;
  final String? email;
  final String role;
  final String? avatar;
  final String? nim;    // Baru
  final String? prodi;  // Baru
  final String? nidn;   // Baru

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    this.avatar,
    this.nim,
    this.prodi,
    this.nidn,
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
    );
  }
}