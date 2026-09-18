enum NotificationType {
  chapter,
  comment,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? imageUrl;
  final String? novelId;
  final String? chapterId;
  final int? chapterNumber;
  final String? authorName;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.novelId,
    this.chapterId,
    this.chapterNumber,
    this.authorName,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationType type = NotificationType.system;
    final typeStr = json['type'] as String? ?? 'system';
    if (typeStr == 'chapter') {
      type = NotificationType.chapter;
    } else if (typeStr == 'comment') {
      type = NotificationType.comment;
    }

    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: type,
      imageUrl: json['image_url'] as String?,
      novelId: json['novel_id'] as String?,
      chapterId: json['chapter_id'] as String?,
      chapterNumber: json['chapter_number'] as int?,
      authorName: json['author_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'image_url': imageUrl,
      'novel_id': novelId,
      'chapter_id': chapterId,
      'chapter_number': chapterNumber,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? imageUrl,
    String? novelId,
    String? chapterId,
    int? chapterNumber,
    String? authorName,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
