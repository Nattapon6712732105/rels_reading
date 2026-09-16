class AuthorInfo {
  final String id;
  final String username;
  final String? email;

  AuthorInfo({
    required this.id,
    required this.username,
    this.email,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) {
    return AuthorInfo(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'นักเขียนนิรนาม',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (email != null) 'email': email,
    };
  }
}

class Novel {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String authorId;
  final AuthorInfo? author;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int chaptersCount;
  final List<String> tags;

  Novel({
    required this.id,
    required this.title,
    this.description = '',
    this.coverUrl = '',
    required this.authorId,
    this.author,
    this.createdAt,
    this.updatedAt,
    this.chaptersCount = 0,
    this.tags = const [],
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    AuthorInfo? author;
    if (json['author'] != null && json['author'] is Map<String, dynamic>) {
      author = AuthorInfo.fromJson(json['author'] as Map<String, dynamic>);
    }

    List<String> parsedTags = [];
    if (json['tags'] != null && json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }

    return Novel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'ไม่มีชื่อเรื่อง',
      description: json['description'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      author: author,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      chaptersCount: json['chapters_count'] as int? ?? 0,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'author_id': authorId,
      if (author != null) 'author': author!.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'chapters_count': chaptersCount,
      'tags': tags,
    };
  }

  String get displayAuthorName => author?.username.isNotEmpty == true ? author!.username : 'นักเขียน';

  Novel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    String? authorId,
    AuthorInfo? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? chaptersCount,
    List<String>? tags,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chaptersCount: chaptersCount ?? this.chaptersCount,
      tags: tags ?? this.tags,
    );
  }
}

