import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/community_repository.dart';
import '../../models/community_post.dart';
import '../../providers/auth_provider.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final DiscussionTopic topic;

  const DiscussionDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final CommunityRepository _communityRepo = CommunityRepository();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late DiscussionTopic _topic;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
    _topic.viewsCount += 1;
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleToggleLike() async {
    HapticFeedback.lightImpact();
    final newLiked = await _communityRepo.toggleLikeTopic(_topic.id);
    if (mounted) {
      setState(() {
        _topic.isLiked = newLiked;
        _topic.likesCount += newLiked ? 1 : -1;
        if (_topic.likesCount < 0) _topic.likesCount = 0;
      });
    }
  }

  Future<void> _handleToggleLikeReply(DiscussionReply reply) async {
    HapticFeedback.selectionClick();
    final newLiked = await _communityRepo.toggleLikeReply(_topic.id, reply.id);
    if (mounted) {
      setState(() {
        reply.isLiked = newLiked;
        reply.likesCount += newLiked ? 1 : -1;
        if (reply.likesCount < 0) reply.likesCount = 0;
      });
    }
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final authorName = user?.username.isNotEmpty == true
        ? user!.username
        : 'นักอ่าน Rels';
    final authorAvatar = user?.avatarUrl;
    final isAuthor = user?.role == 'author' || user?.role == 'admin';

    setState(() => _isSubmitting = true);

    try {
      final newReply = await _communityRepo.addReply(
        topicId: _topic.id,
        author: authorName,
        authorAvatar: authorAvatar,
        isAuthor: isAuthor,
        content: text,
      );

      _replyController.clear();

      if (mounted) {
        FocusScope.of(context).unfocus();
        setState(() {
          _topic.replies.add(newReply);
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งความคิดเห็นเรียบร้อยแล้ว'),
            backgroundColor: AppTheme.primary,
            duration: Duration(seconds: 2),
          ),
        );

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ส่งความคิดเห็นไม่สำเร็จ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dt) {
    try {
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'เมื่อสักครู่';
      if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
      if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
      if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
      return DateFormat('d MMM yyyy', 'th').format(dt);
    } catch (_) {
      const thaiMonths = [
        '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
      ];
      final m = (dt.month >= 1 && dt.month <= 12) ? thaiMonths[dt.month] : '${dt.month}';
      return '${dt.day} $m ${dt.year + 543}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13141D),
        elevation: 0,
        title: const Text(
          'ห้องพูดคุยนักอ่าน',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'แชร์กระทู้นี้',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${_topic.title}\nห้องพูดคุย Rels Reading'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('คัดลอกลิงก์กระทู้แล้ว!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Discussion Main Card
                      _buildMainTopicCard(),
                      const SizedBox(height: 24),

                      // Comments Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.forum_rounded, color: AppTheme.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'ความคิดเห็น (${_topic.replies.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Comments / Replies List
                      if (_topic.replies.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161722),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF262838)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 36, color: Color(0xFF64748B)),
                              SizedBox(height: 8),
                              Text(
                                'ยังไม่มีความคิดเห็น เป็นคนแรกที่เริ่มพูดคุยเลย!',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _topic.replies.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reply = _topic.replies[index];
                            return _buildReplyCard(reply);
                          },
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sticky Reply Bar
          _buildReplyInputBar(user),
        ],
      ),
    );
  }

  Widget _buildMainTopicCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF282B3E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Chip & Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  _topic.category,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_topic.isPinned) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.push_pin_rounded, size: 12, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('ปักหมุด', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Text(
                _formatTime(_topic.createdAt),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            _topic.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Author Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                backgroundImage: _topic.authorAvatar != null && _topic.authorAvatar!.isNotEmpty
                    ? NetworkImage(_topic.authorAvatar!)
                    : null,
                child: _topic.authorAvatar == null || _topic.authorAvatar!.isEmpty
                    ? Text(
                        _topic.author.isNotEmpty ? _topic.author[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _topic.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (_topic.isAuthor) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple.withOpacity(0.4)),
                          ),
                          child: const Text(
                            'นักเขียน',
                            style: TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Text(
                    'ผู้สร้างกระทู้',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          const Divider(color: Color(0xFF262838), height: 1),
          const SizedBox(height: 16),

          // Content Body
          SelectableText(
            _topic.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 20),

          // Action Stats Row (Like, Comments, Views)
          Row(
            children: [
              // Like Button
              InkWell(
                onTap: _handleToggleLike,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _topic.isLiked ? Colors.redAccent.withOpacity(0.15) : const Color(0xFF1E202C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _topic.isLiked ? Colors.redAccent.withOpacity(0.4) : const Color(0xFF2F3244),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _topic.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _topic.isLiked ? Colors.redAccent : const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_topic.likesCount}',
                        style: TextStyle(
                          color: _topic.isLiked ? Colors.redAccent : const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Comments Count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E202C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2F3244)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF94A3B8), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_topic.replies.length} ความคิดเห็น',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Views Count
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF64748B), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    '${_topic.viewsCount} ครั้ง',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(DiscussionReply reply) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151620),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF232535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                backgroundImage: reply.authorAvatar != null && reply.authorAvatar!.isNotEmpty
                    ? NetworkImage(reply.authorAvatar!)
                    : null,
                child: reply.authorAvatar == null || reply.authorAvatar!.isEmpty
                    ? Text(
                        reply.author.isNotEmpty ? reply.author[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      reply.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    if (reply.isAuthor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'นักเขียน',
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _formatTime(reply.createdAt),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Content
          SelectableText(
            reply.content,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 8),

          // Reply Like Button
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _handleToggleLikeReply(reply),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reply.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 14,
                      color: reply.isLiked ? Colors.redAccent : const Color(0xFF64748B),
                    ),
                    if (reply.likesCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${reply.likesCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: reply.isLiked ? Colors.redAccent : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInputBar(dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13141D),
        border: const Border(top: BorderSide(color: Color(0xFF262838))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppTheme.primary,
                  backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                      ? Text(
                          user?.username.isNotEmpty == true ? user!.username[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppTheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'แสดงความคิดเห็นในกระทู้นี้...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1E202C),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF2E3144)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF2E3144)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _isSubmitting ? null : _submitReply,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        )
                      : const Icon(Icons.send_rounded, color: AppTheme.primary),
                  tooltip: 'ส่งความคิดเห็น',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
