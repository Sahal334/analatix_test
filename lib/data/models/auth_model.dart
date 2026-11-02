class AuthModel {
  const AuthModel({
    required this.accessToken,
    required this.refreshToken,
    this.id = 0,
    this.username = '',
    this.email = '',
  });

  final String accessToken;
  final String refreshToken;
  final int id;
  final String username;
  final String email;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: (json['accessToken'] ?? json['token'] ?? '') as String,
      refreshToken: (json['refreshToken'] ?? '') as String,
      id: (json['id'] as int?) ?? 0,
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'id': id,
      'username': username,
      'email': email,
    };
  }

  @override
  String toString() => 'AuthModel(id: $id, username: $username)';
}
