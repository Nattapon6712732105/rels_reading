import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../models/community_post.dart';

class CommunityRepository {
  static const String _storageKey = 'community_topics_v3';
  static const String _cloudStorageUrl =
      'https://usfntxkopzkgkvcaywdx.supabase.co/storage/v1/object/public/covers/community/topics.json';

  /// Default Seed Topics matching the screenshot and popular discussions
  List<DiscussionTopic> _getSeedTopics() {
    return [
      DiscussionTopic(
        id: 'topic_testsss',
        title: 'testsss',
        author: 'เทพไม่รวมกลุ่ม',
        isAuthor: true,
        category: 'พูดคุยนิยาย',
        content: 'กระทู้พูดคุยและแลกเปลี่ยนความคิดเห็นเกี่ยวกับนิยายเรื่อง คนคุก และผลงานใหม่ๆ ครับ',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        viewsCount: 15,
        likesCount: 0,
        isLiked: false,
        isPinned: false,
        replies: [],
      ),
      DiscussionTopic(
        id: 'topic-1',
        title: 'ห้องพูดคุยนักอ่าน: หวนคืนสู่บัลลังก์จอมราชันย์',
        author: 'หลินเฟิ่งแฟนคลับ',
        isAuthor: false,
        category: 'พูดคุยนิยาย',
        content: 'หลังจากอ่านตอนที่ 2 จบ คิดว่าวิชากลืนสวรรค์ของหลินเฟิงจะพัฒนาไปในทิศทางไหนต่อครับ? ฉากต่อสู้เปิดเรื่องทำออกมาได้อลังการและน่าติดตามมาก พระเอกกลับมาเกิดใหม่ในร่างตระกูลตกอับแบบนี้ รับรองว่าสะใจแน่นอน ทุกคนคิดเห็นยังไงกันบ้างครับ?',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        viewsCount: 342,
        likesCount: 52,
        isLiked: false,
        isPinned: true,
        replies: [
          DiscussionReply(
            id: 'rep-1-1',
            author: 'พยัคฆ์ทมิฬคำราม',
            isAuthor: true,
            content: 'ขอบคุณที่ติดตามนะครับ! ในตอนต่อไปหลินเฟิงจะได้พบกับสมบัติชิ้นสำคัญในถ้ำโบราณแน่นอนครับ ฝากติดตามด้วยนะครับ',
            createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
            likesCount: 18,
          ),
          DiscussionReply(
            id: 'rep-1-2',
            author: 'ยอดฝีมือกระบี่เดียว',
            content: 'ฉากเปิดเรื่องมันส์มาก ชอบตอนที่พระเอกปล่อยพลังปราณกลืนสวรรค์สะกดทุกคน!',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            likesCount: 9,
          ),
          DiscussionReply(
            id: 'rep-1-3',
            author: 'หนอนหนังสือนิรนาม',
            content: 'เนื้อเรื่องกระชับไม่ยืดเยื้อ เป็นกำลังใจให้ผู้แต่งครับ รออ่านตอนต่อไปนะครับ',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            likesCount: 5,
          ),
        ],
      ),
      DiscussionTopic(
        id: 'topic-2',
        title: 'แชร์เทคนิคการเปิดเรื่องนิยายให้น่าติดตาม',
        author: 'พยัคฆ์ทมิฬคำราม',
        isAuthor: true,
        category: 'เทคนิคการเขียน',
        content: 'สวัสดีเพื่อนๆ นักเขียนและนักอ่านทุกท่านครับ วันนี้อยากมาแชร์เทคนิคที่ผมใช้เป็นประจำในการเขียนบทนำ (Opening Hook):\n\n1. เริ่มต้นด้วยความขัดแย้งหรือสถานการณ์วิกฤตทันที อย่าเพิ่งบรรยายฉากหลังยืดยาว\n2. แสดงเอกลักษณ์หรือปมเด่นของตัวเอกให้ชัดเจนใน 3 ย่อหน้าแรก\n3. ทิ้งคำถามหรือข้อสงสัยให้คนอ่านอยากรู้ต่อท้ายบทเสมอ\n\nเพื่อนๆ มีเทคนิคอะไรแนะนำเพิ่มเติมมาแลกเปลี่ยนกันได้เลยนะครับ!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        viewsCount: 680,
        likesCount: 89,
        isLiked: false,
        isPinned: true,
        replies: [
          DiscussionReply(
            id: 'rep-2-1',
            author: 'บุปผาโปรยปราย',
            isAuthor: true,
            content: 'เห็นด้วยมากๆ เลยค่ะ นิยายรักของดิฉันก็เน้นเปิดด้วยสถานการณ์ที่นางเอกต้องตัดสินใจเอาตัวรอด ทำให้คนอ่านลุ้นตามตั้งแต่หน้าแรก',
            createdAt: DateTime.now().subtract(const Duration(hours: 20)),
            likesCount: 14,
          ),
          DiscussionReply(
            id: 'rep-2-2',
            author: 'นักเขียนมือใหม่ไฟแรง',
            content: 'เป็นประโยชน์มากครับ ขอนำเทคนิคนี้ไปปรับใช้กับนิยายเรื่องแรกของผมเลยครับ ขอบคุณครับ',
            createdAt: DateTime.now().subtract(const Duration(hours: 15)),
            likesCount: 7,
          ),
        ],
      ),
      DiscussionTopic(
        id: 'topic-3',
        title: 'แนะนำนิยายสายไซไฟ-โลกอนาคต ประจำสัปดาห์',
        author: 'NeonGhost',
        isAuthor: true,
        category: 'แนะนำนิยาย',
        content: 'สัปดาห์นี้อยากชวนทุกคนมาแนะนำนิยายแนว Sci-Fi, Cyberpunk หรือโลกอนาคตที่มีการผสมผสานเทคโนโลยีล้ำสมัย ชิปไซเบอร์เนติกส์ และการต่อสู้ในเมืองนีออน ใครมีเรื่องโปรดในใจหรืออยากให้แนวนี้มีทิศทางแบบไหน มาร่วมคอมเมนต์พูดคุยกันได้เลยครับ!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        viewsCount: 420,
        likesCount: 38,
        isLiked: false,
        replies: [
          DiscussionReply(
            id: 'rep-3-1',
            author: 'CyberRider',
            content: 'ไซเบอร์พังค์ 2099 สนุกมาก ชอบบรรยากาศไนท์ซิตี้กับระบบแฮกเกอร์ อยากให้มีตอนใหม่ไวๆ ครับ',
            createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
            likesCount: 8,
          ),
        ],
      ),
      DiscussionTopic(
        id: 'topic-4',
        title: 'ห้องพูดคุยนักอ่าน: นิยาย "คนคุก" ตอนที่ 3 โหด ดิบ ได้ใจมาก!',
        author: 'สายอ่านฮาร์ดคอร์',
        isAuthor: false,
        category: 'พูดคุยนิยาย',
        content: 'พึ่งอ่านตอนที่ 3 (คุก3) จบไป บอกเลยว่าเนื้อเรื่องเดือดและน่าติดตามมากครับ ตัวเอกสู้ยิบตาและไม่ยอมจำนนต่ออิทธิพลมืดในคุก ใครที่ชอบนิยายแนวแอ็กชัน ดาร์กๆ ไม่ควรพลาดเรื่องนี้เลยครับ รอตอนที่ 4 อยู่นะครับท่านนักเขียน เทพไม่รวมกลุ่ม!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        viewsCount: 185,
        likesCount: 29,
        isLiked: false,
        replies: [
          DiscussionReply(
            id: 'rep-4-1',
            author: 'เทพไม่รวมกลุ่ม',
            isAuthor: true,
            content: 'ขอบคุณมากครับที่ชอบและให้กำลังใจ ตอนที่ 4 กำลังเร่งเขียนอยู่ จะพยายามอัปเดตให้เร็วที่สุดครับ!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
            likesCount: 15,
          ),
          DiscussionReply(
            id: 'rep-4-2',
            author: 'นักอ่านแดนสนธยา',
            content: 'ติดตามมาตั้งแต่ตอนที่ 1 สนุกจริงครับ ยืนยันอีกเสียง!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
            likesCount: 4,
          ),
        ],
      ),
    ];
  }

  /// Read local cached topics
  Future<List<DiscussionTopic>> _getLocalTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => DiscussionTopic.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Merge remote and local topics to preserve newly created items
  List<DiscussionTopic> _mergeTopics(List<DiscussionTopic> remote, List<DiscussionTopic> local) {
    final Map<String, DiscussionTopic> map = {};
    for (final t in remote) {
      map[t.id] = t;
    }
    for (final t in local) {
      map[t.id] = t;
    }
    final list = map.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Get all topics (Synced from Backend / Supabase Cloud Storage, with local cache fallback)
  Future<List<DiscussionTopic>> getTopics() async {
    final local = await _getLocalTopics();

    // 1. Try Backend API
    try {
      final res = await ApiClient.dio.get(
        '/community/topics',
        options: Options(receiveTimeout: const Duration(seconds: 4)),
      );
      if (res.data['success'] == true && res.data['data'] is List) {
        final List list = res.data['data'];
        final topics = list.map((e) => DiscussionTopic.fromJson(e as Map<String, dynamic>)).toList();
        if (topics.isNotEmpty) {
          final merged = _mergeTopics(topics, local);
          await _saveLocalTopics(merged);
          return merged;
        }
      }
    } catch (_) {}

    // 2. Try Public Supabase Cloud Storage
    try {
      final dio = Dio();
      final res = await dio.get(
        _cloudStorageUrl,
        options: Options(receiveTimeout: const Duration(seconds: 4)),
      );
      if (res.data != null) {
        List<dynamic> list;
        if (res.data is List) {
          list = res.data as List;
        } else if (res.data is String) {
          list = jsonDecode(res.data as String) as List;
        } else {
          list = [];
        }

        final topics = list.map((e) => DiscussionTopic.fromJson(e as Map<String, dynamic>)).toList();
        if (topics.isNotEmpty) {
          final merged = _mergeTopics(topics, local);
          await _saveLocalTopics(merged);
          return merged;
        }
      }
    } catch (_) {}

    // 3. Fallback to Local Storage
    if (local.isNotEmpty) {
      return local;
    }

    // 4. Default Seed Topics
    final seeds = _getSeedTopics();
    await _saveLocalTopics(seeds);
    return seeds;

  }

  /// Save topics list to local cache
  Future<void> _saveLocalTopics(List<DiscussionTopic> topics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(topics.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  /// Get topic by ID
  Future<DiscussionTopic?> getTopicById(String id) async {
    final topics = await getTopics();
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new discussion topic
  Future<DiscussionTopic> createTopic({
    required String title,
    required String author,
    String? authorAvatar,
    bool isAuthor = false,
    required String category,
    required String content,
  }) async {
    DiscussionTopic? createdFromBackend;

    // 1. Try Backend API
    try {
      final res = await ApiClient.dio.post(
        '/community/topics',
        data: {
          'title': title.trim(),
          'author': author.trim(),
          'author_avatar': authorAvatar,
          'is_author': isAuthor,
          'category': category,
          'content': content.trim(),
        },
      );
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        createdFromBackend = DiscussionTopic.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}

    final newTopic = createdFromBackend ??
        DiscussionTopic(
          id: 'topic_${DateTime.now().millisecondsSinceEpoch}',
          title: title.trim(),
          author: author.trim().isNotEmpty ? author.trim() : 'นักอ่าน Rels',
          authorAvatar: authorAvatar,
          isAuthor: isAuthor,
          category: category,
          content: content.trim(),
          createdAt: DateTime.now(),
          viewsCount: 1,
          likesCount: 0,
          isLiked: false,
          replies: [],
        );

    final topics = await getTopics();
    topics.removeWhere((t) => t.id == newTopic.id);
    topics.insert(0, newTopic);
    await _saveLocalTopics(topics);
    return newTopic;
  }

  /// Add reply to discussion topic
  Future<DiscussionReply> addReply({
    required String topicId,
    required String author,
    String? authorAvatar,
    bool isAuthor = false,
    required String content,
  }) async {
    DiscussionReply? replyFromBackend;

    // 1. Try Backend API
    try {
      final res = await ApiClient.dio.post(
        '/community/topics/$topicId/replies',
        data: {
          'author': author.trim(),
          'author_avatar': authorAvatar,
          'is_author': isAuthor,
          'content': content.trim(),
        },
      );
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        replyFromBackend = DiscussionReply.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}

    final newReply = replyFromBackend ??
        DiscussionReply(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          author: author.trim().isNotEmpty ? author.trim() : 'นักอ่าน Rels',
          authorAvatar: authorAvatar,
          isAuthor: isAuthor,
          content: content.trim(),
          createdAt: DateTime.now(),
          likesCount: 0,
          isLiked: false,
        );

    final topics = await getTopics();
    final index = topics.indexWhere((t) => t.id == topicId);
    if (index != -1) {
      topics[index].replies.add(newReply);
      await _saveLocalTopics(topics);
    }

    return newReply;
  }

  /// Toggle like on a topic
  Future<bool> toggleLikeTopic(String topicId) async {
    // 1. Try Backend API
    try {
      await ApiClient.dio.post('/community/topics/$topicId/like');
    } catch (_) {}


    final topics = await getTopics();
    final index = topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return false;

    final topic = topics[index];
    final bool newLiked = !topic.isLiked;
    topic.isLiked = newLiked;
    topic.likesCount += newLiked ? 1 : -1;
    if (topic.likesCount < 0) topic.likesCount = 0;

    await _saveLocalTopics(topics);
    return newLiked;
  }

  /// Toggle like on a reply
  Future<bool> toggleLikeReply(String topicId, String replyId) async {
    final topics = await getTopics();
    final index = topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return false;

    final replyIndex = topics[index].replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return false;

    final reply = topics[index].replies[replyIndex];
    final bool newLiked = !reply.isLiked;
    reply.isLiked = newLiked;
    reply.likesCount += newLiked ? 1 : -1;
    if (reply.likesCount < 0) reply.likesCount = 0;

    await _saveLocalTopics(topics);
    return newLiked;
  }
}
