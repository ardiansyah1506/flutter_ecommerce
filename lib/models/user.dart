class User {
  final int userId;
  final String role;
  final String kategori;

  User({required this.userId, required this.role, required this.kategori});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      role: json['role'],
      kategori: json['kategori'],
    );
  }
}
