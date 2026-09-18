import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/community_post.dart';

class CommunityRepository {
  static const String _storageKey = 'community_topics_v2';

  /// Default Seed Topics matching the screenshot and popular discussions
  List<DiscussionTopic> _getSeedTopics() {
    return [
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

  /// Get all topics (from SharedPreferences or seed default)
  Future<List<DiscussionTopic>> getTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final topics = list.map((e) => DiscussionTopic.fromJson(e as Map<String, dynamic>)).toList();
        return topics;
      }
    } catch (_) {}

    // Fallback to initial seeds and persist
    final seeds = _getSeedTopics();
    await _saveTopics(seeds);
    return seeds;
  }

  /// Save topics list to SharedPreferences
  Future<void> _saveTopics(List<DiscussionTopic> topics) async {
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
    final topics = await getTopics();
    final newTopic = DiscussionTopic(
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

    topics.insert(0, newTopic);
    await _saveTopics(topics);
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
    final topics = await getTopics();
    final index = topics.indexWhere((t) => t.id == topicId);
    if (index == -1) {
      throw Exception('ไม่พบกระทู้ที่ระบุ');
    }

    final newReply = DiscussionReply(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      author: author.trim().isNotEmpty ? author.trim() : 'นักอ่าน Rels',
      authorAvatar: authorAvatar,
      isAuthor: isAuthor,
      content: content.trim(),
      createdAt: DateTime.now(),
      likesCount: 0,
      isLiked: false,
    );

    topics[index].replies.add(newReply);
    await _saveTopics(topics);
    return newReply;
  }

  /// Toggle like on a topic
  Future<bool> toggleLikeTopic(String topicId) async {
    final topics = await getTopics();
    final index = topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return false;

    final topic = topics[index];
    final bool newLiked = !topic.isLiked;
    topic.isLiked = newLiked;
    topic.likesCount += newLiked ? 1 : -1;
    if (topic.likesCount < 0) topic.likesCount = 0;

    await _saveTopics(topics);
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

    await _saveTopics(topics);
    return newLiked;
  }
}
