class User {
  final int id;
  final String username;
  final String role;
  final String? fullName;
  final String? email;
  final String? department;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.email,
    this.department,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      fullName: json['full_name'],
      email: json['email'],
      department: json['department'],
    );
  }
}
