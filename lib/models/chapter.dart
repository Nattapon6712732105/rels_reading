class Chapter {
  final String id;
  final String novelId;
  final int chapterNumber;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Chapter({
    required this.id,
    required this.novelId,
    required this.chapterNumber,
    required this.title,
    this.content = '',
    this.createdAt,
    this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ?? '',
      novelId: json['novel_id'] as String? ?? '',
      chapterNumber: json['chapter_number'] is int
          ? json['chapter_number'] as int
          : int.tryParse(json['chapter_number']?.toString() ?? '1') ?? 1,
      title: json['title'] as String? ?? 'ตอนที่',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novel_id': novelId,
      'chapter_number': chapterNumber,
      'title': title,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
