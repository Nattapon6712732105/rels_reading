class DiscussionReply {
  final String id;
  final String author;
  final String? authorAvatar;
  final bool isAuthor;
  final String content;
  final DateTime createdAt;
  int likesCount;
  bool isLiked;

  DiscussionReply({
    required this.id,
    required this.author,
    this.authorAvatar,
    this.isAuthor = false,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory DiscussionReply.fromJson(Map<String, dynamic> json) {
    return DiscussionReply(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'ผู้อ่าน',
      authorAvatar: json['author_avatar'] as String?,
      isAuthor: json['is_author'] as bool? ?? false,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'author_avatar': authorAvatar,
      'is_author': isAuthor,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }
}

class DiscussionTopic {
  final String id;
  final String title;
  final String author;
  final String? authorAvatar;
  final bool isAuthor;
  final String category; // 'พูดคุยนิยาย' | 'เทคนิคการเขียน' | 'แนะนำนิยาย' | 'ทั่วไป'
  final String content;
  final DateTime createdAt;
  int viewsCount;
  int likesCount;
  bool isLiked;
  final bool isPinned;
  final List<DiscussionReply> replies;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.author,
    this.authorAvatar,
    this.isAuthor = false,
    required this.category,
    required this.content,
    required this.createdAt,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    List<DiscussionReply>? replies,
  }) : replies = replies ?? [];

  int get repliesCount => replies.length;

  factory DiscussionTopic.fromJson(Map<String, dynamic> json) {
    var rawReplies = json['replies'] as List<dynamic>? ?? [];
    var parsedReplies = rawReplies
        .map((e) => DiscussionReply.fromJson(e as Map<String, dynamic>))
        .toList();

    return DiscussionTopic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? 'ผู้อ่าน',
      authorAvatar: json['author_avatar'] as String?,
      isAuthor: json['is_author'] as bool? ?? false,
      category: json['category'] as String? ?? 'ทั่วไป',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      viewsCount: json['views_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      replies: parsedReplies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'author_avatar': authorAvatar,
      'is_author': isAuthor,
      'category': category,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'views_count': viewsCount,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'is_pinned': isPinned,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}
