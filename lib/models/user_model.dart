class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // الأدوار: 'admin', 'reader', 'collector'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}
