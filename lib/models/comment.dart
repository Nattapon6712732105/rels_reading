class CommentUser {
  final String id;
  final String username;

  CommentUser({
    required this.id,
    required this.username,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'ผู้อ่าน',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}

class Comment {
  final String id;
  final String chapterId;
  final String userId;
  final String content;
  final CommentUser? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.chapterId,
    required this.userId,
    required this.content,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    CommentUser? user;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      user = CommentUser.fromJson(json['user'] as Map<String, dynamic>);
    }

    return Comment(
      id: json['id'] as String? ?? '',
      chapterId: json['chapter_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      user: user,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'user_id': userId,
      'content': content,
      if (user != null) 'user': user!.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
