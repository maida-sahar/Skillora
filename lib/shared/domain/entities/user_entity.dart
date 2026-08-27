class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'user' | 'admin'
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'admin';
}
