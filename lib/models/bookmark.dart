import 'novel.dart';

class Bookmark {
  final String id;
  final String userId;
  final String novelId;
  final Novel? novel;
  final DateTime? createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.novelId,
    this.novel,
    this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    Novel? novel;
    if (json['novel'] != null && json['novel'] is Map<String, dynamic>) {
      novel = Novel.fromJson(json['novel'] as Map<String, dynamic>);
    }

    return Bookmark(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      novelId: json['novel_id'] as String? ?? '',
      novel: novel,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'novel_id': novelId,
      if (novel != null) 'novel': novel!.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
