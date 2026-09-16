class User {
  final String id;
  final String email;
  final String username;
  final String role;
  final String authProvider;
  final String? googleId;
  final String? lineUserId;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.role = 'user',
    this.authProvider = 'local',
    this.googleId,
    this.lineUserId,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      authProvider: json['auth_provider'] as String? ?? 'local',
      googleId: json['google_id'] as String?,
      lineUserId: json['line_user_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'auth_provider': authProvider,
      'google_id': googleId,
      'line_user_id': lineUserId,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isLineLinked => lineUserId != null && lineUserId!.trim().isNotEmpty;
  bool get isGoogleAuth => authProvider == 'google';

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? role,
    String? authProvider,
    String? googleId,
    String? lineUserId,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      authProvider: authProvider ?? this.authProvider,
      googleId: googleId ?? this.googleId,
      lineUserId: lineUserId ?? this.lineUserId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
