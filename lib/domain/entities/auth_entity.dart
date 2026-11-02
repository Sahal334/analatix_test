class AuthEntity {
  const AuthEntity({
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

  AuthEntity copyWith({
    String? accessToken,
    String? refreshToken,
    int? id,
    String? username,
    String? email,
  }) {
    return AuthEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          accessToken == other.accessToken;

  @override
  int get hashCode => Object.hash(id, accessToken);

  @override
  String toString() => 'AuthEntity(id: $id, username: $username)';
}
