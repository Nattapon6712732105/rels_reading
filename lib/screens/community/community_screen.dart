import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../models/app_notification.dart';
import '../../models/community_post.dart';
import '../../providers/auth_provider.dart';
import '../novel/novel_detail_screen.dart';
import 'create_discussion_dialog.dart';
import 'discussion_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Notification tab state
  final NotificationRepository _notificationRepo = NotificationRepository();
  List<AppNotification> _notifications = [];
  bool _isLoadingNotifications = true;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['ทั้งหมด', 'ตอนใหม่', 'ความคิดเห็น', 'ระบบ'];
  bool _isBannerDismissed = false;
  bool _isSendingTestNotification = false;

  // Community tab state
  final CommunityRepository _communityRepo = CommunityRepository();
  List<DiscussionTopic> _topics = [];
  bool _isLoadingTopics = true;
  int _selectedCommunityCategoryIndex = 0;
  final List<String> _communityCategories = ['ทั้งหมด', 'พูดคุยนิยาย', 'เทคนิคการเขียน', 'แนะนำนิยาย', 'ทั่วไป'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _loadBannerDismissedState();
    _loadNotifications();
    _loadTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBannerDismissedState() async {
    try {
      final auth = context.read<AuthProvider>();
      final key = 'line_oa_banner_dismissed_${auth.user?.id ?? "guest"}';
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isBannerDismissed = prefs.getBool(key) ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _dismissBanner() async {
    try {
      final auth = context.read<AuthProvider>();
      final key = 'line_oa_banner_dismissed_${auth.user?.id ?? "guest"}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (_) {}
    if (mounted) {
      setState(() => _isBannerDismissed = true);
    }
  }

  Future<void> _loadNotifications() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id ?? 'guest';

    setState(() => _isLoadingNotifications = true);
    try {
      final list = await _notificationRepo.getNotifications(userId);
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoadingNotifications = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingNotifications = false);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    HapticFeedback.lightImpact();
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id ?? 'guest';
    final unreadIds = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();

    if (unreadIds.isEmpty) return;

    await _notificationRepo.markAllAsRead(userId, unreadIds);
    if (mounted) {
      setState(() {
        for (var n in _notifications) {
          n.isRead = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ทำเครื่องหมายว่าอ่านแล้วทั้งหมดแล้ว'),
          backgroundColor: AppTheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(AppNotification notif) async {
    HapticFeedback.selectionClick();
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id ?? 'guest';

    if (!notif.isRead) {
      setState(() {
        notif.isRead = true;
      });
      await _notificationRepo.markAsRead(userId, notif.id);
    }

    if (notif.novelId != null && notif.novelId!.isNotEmpty) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NovelDetailScreen(novelId: notif.novelId!),
          ),
        );
      }
    }
  }

  Future<void> _sendTestLineNotification() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLineLinked) {
      _showLineConnectDialog(context);
      return;
    }

    setState(() => _isSendingTestNotification = true);
    HapticFeedback.mediumImpact();

    try {
      final success = await auth.sendTestLineNotification();
      if (mounted) {
        setState(() => _isSendingTestNotification = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔔 ส่งการแจ้งเตือนทดสอบเข้าแชท LINE ของคุณเรียบร้อยแล้ว!'),
              backgroundColor: Color(0xFF06C755),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ส่งแจ้งเตือนไม่สำเร็จ กรุณาตรวจสอบการผูกบัญชี LINE OA'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingTestNotification = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoadingTopics = true);
    try {
      final list = await _communityRepo.getTopics();
      if (mounted) {
        setState(() {
          _topics = list;
          _isLoadingTopics = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingTopics = false);
      }
    }
  }

  Future<void> _openCreateDiscussionDialog() async {
    HapticFeedback.lightImpact();
    final newTopic = await CreateDiscussionDialog.show(context);
    if (newTopic != null && mounted) {
      setState(() {
        _topics.insert(0, newTopic);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สร้างกระทู้สำเร็จแล้ว! 🎉'),
          backgroundColor: AppTheme.primary,
          duration: Duration(seconds: 2),
        ),
      );

      // Open newly created topic
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiscussionDetailScreen(topic: newTopic),
        ),
      ).then((_) => _loadTopics());
    }
  }

  void _showLineConnectDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF161722),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06C755).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF06C755), size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รับแจ้งเตือนผ่าน LINE OA',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'สแกนเพียง 1 ครั้งต่อผู้ใช้',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      AppConfig.lineOaQrAsset,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 180,
                        height: 180,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'แจ้งเตือนตอนใหม่จะส่งเข้า LINE โดยตรง ไม่รบกวนหน้าเว็บ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: () => launchUrlString(AppConfig.lineOaUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('เปิดแอป LINE เพื่อเพิ่มเพื่อน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06C755),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),

                OutlinedButton.icon(
                  onPressed: () async {
                    await auth.fetchLineStatus();
                    if (ctx.mounted) {
                      if (auth.isLineLinked) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ผูกบัญชี LINE เรียบร้อยแล้ว!'),
                            backgroundColor: Color(0xFF06C755),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('แอดเพื่อนแล้วสามารถเปิดอ่านและรับแจ้งเตือนได้เลย'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF94A3B8)),
                  label: const Text('ตรวจสอบสถานะ', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    side: const BorderSide(color: Color(0xFF2E3147)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
    return DateFormat('d MMM', 'th').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0F14),
        title: const Text(
          'การแจ้งเตือนและคอมมูนิตี้',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_tabController.index == 1)
            TextButton.icon(
              onPressed: _openCreateDiscussionDialog,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.primary),
              label: const Text(
                'ตั้งกระทู้ใหม่',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('การแจ้งเตือน'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: AppTheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'ห้องพูดคุยนักอ่าน'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildCommunityTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _openCreateDiscussionDialog,
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              icon: const Icon(Icons.add_comment_rounded, size: 20),
              label: const Text('ตั้งกระทู้ใหม่', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildNotificationsTab() {
    final auth = context.watch<AuthProvider>();
    final bool isLinked = auth.isLineLinked;

    // Filter notifications
    List<AppNotification> filteredNotifications = _notifications;
    if (_selectedFilterIndex == 1) {
      filteredNotifications = _notifications.where((n) => n.type == NotificationType.chapter).toList();
    } else if (_selectedFilterIndex == 2) {
      filteredNotifications = _notifications.where((n) => n.type == NotificationType.comment).toList();
    } else if (_selectedFilterIndex == 3) {
      filteredNotifications = _notifications.where((n) => n.type == NotificationType.system).toList();
    }

    final int unreadCount = _notifications.where((n) => !n.isRead).length;

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If already linked: show subtle status pill with test notification button
                if (isLinked)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06C755).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF06C755).withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF06C755), size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'ผูก LINE OA แล้ว • ระบบจะส่งแจ้งเตือนตอนใหม่ผ่าน LINE โดยตรง',
                            style: TextStyle(color: Color(0xFF06C755), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _isSendingTestNotification ? null : _sendTestLineNotification,
                          icon: _isSendingTestNotification
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06C755)),
                                )
                              : const Icon(Icons.notifications_active_rounded, size: 14, color: Color(0xFF06C755)),
                          label: const Text(
                            'ทดสอบส่งเข้า LINE',
                            style: TextStyle(color: Color(0xFF06C755), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            backgroundColor: const Color(0xFF06C755).withOpacity(0.12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  )
                // If not linked and not dismissed: show LINE OA card
                else if (!_isBannerDismissed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3A22), Color(0xFF161822)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF06C755).withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF06C755),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'รับแจ้งเตือนผ่าน LINE OA',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'สแกน 1 ครั้งเพื่อรับการแจ้งเตือนตอนใหม่ผ่านแชท LINE โดยตรง ไม่รบกวนหน้าเว็บ',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () => _showLineConnectDialog(context),
                                icon: const Icon(Icons.qr_code_rounded, size: 16),
                                label: const Text('เชื่อมต่อ LINE Official Account'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF06C755),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                          tooltip: 'ซ่อนการแจ้งเตือนนี้',
                          onPressed: _dismissBanner,
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                // Filter Chips & Mark All Read Action
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_filters.length, (i) {
                            final isSelected = _selectedFilterIndex == i;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(_filters[i]),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedFilterIndex = i);
                                },
                                selectedColor: AppTheme.primary.withOpacity(0.2),
                                backgroundColor: const Color(0xFF1B1C26),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppTheme.primary : const Color(0xFF94A3B8),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primary : const Color(0xFF27293A),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: _markAllAsRead,
                        child: const Text(
                          'อ่านทั้งหมดแล้ว',
                          style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notification Content
                if (_isLoadingNotifications)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else if (filteredNotifications.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1B24),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2B2D3C)),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'ไม่มีการแจ้งเตือนในหมวดนี้',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'การแจ้งเตือนตอนใหม่และข้อความจะปรากฏที่นี่',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = filteredNotifications[index];
                      return _buildNotificationCard(notif);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    Color typeColor;
    String typeLabel;
    IconData typeIcon;

    switch (notif.type) {
      case NotificationType.chapter:
        typeColor = const Color(0xFF06C755);
        typeLabel = 'ตอนใหม่';
        typeIcon = Icons.menu_book_rounded;
        break;
      case NotificationType.comment:
        typeColor = Colors.purpleAccent;
        typeLabel = 'ความคิดเห็น';
        typeIcon = Icons.chat_bubble_rounded;
        break;
      case NotificationType.system:
        typeColor = Colors.amber;
        typeLabel = 'ระบบ';
        typeIcon = Icons.info_outline_rounded;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNotificationTap(notif),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? const Color(0xFF151620) : const Color(0xFF181B28),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead ? const Color(0xFF242636) : AppTheme.primary.withOpacity(0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image or Icon
              if (notif.imageUrl != null && notif.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    notif.imageUrl!,
                    width: 48,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 64,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
              const SizedBox(width: 14),

              // Title and Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(notif.createdAt),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                        const Spacer(),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityTab() {
    // Filter topics by category
    List<DiscussionTopic> filteredTopics = _topics;
    if (_selectedCommunityCategoryIndex > 0) {
      final selectedCat = _communityCategories[_selectedCommunityCategoryIndex];
      filteredTopics = _topics.where((t) => t.category == selectedCat).toList();
    }

    return RefreshIndicator(
      onRefresh: _loadTopics,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter Chips & Create Post Button
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_communityCategories.length, (i) {
                            final isSelected = _selectedCommunityCategoryIndex == i;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(_communityCategories[i]),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedCommunityCategoryIndex = i);
                                },
                                selectedColor: AppTheme.primary.withOpacity(0.2),
                                backgroundColor: const Color(0xFF1B1C26),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppTheme.primary : const Color(0xFF94A3B8),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primary : const Color(0xFF27293A),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Topics List
                if (_isLoadingTopics)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else if (filteredTopics.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.forum_outlined, size: 48, color: Color(0xFF64748B)),
                          const SizedBox(height: 14),
                          const Text(
                            'ยังไม่มีกระทู้ในหมวดหมู่นี้',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'เป็นคนแรกที่เปิดห้องพูดคุยในหมวดหมู่นี้ได้เลย!',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openCreateDiscussionDialog,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('ตั้งกระทู้ใหม่เลย'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTopics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final topic = filteredTopics[i];
                      return _buildTopicCard(topic);
                    },
                  ),
                const SizedBox(height: 60), // Padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(DiscussionTopic topic) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscussionDetailScreen(topic: topic),
            ),
          ).then((_) => _loadTopics());
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161722),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: topic.isPinned ? AppTheme.primary.withOpacity(0.4) : const Color(0xFF262838),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: const Icon(Icons.forum_rounded, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            topic.category,
                            style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (topic.isPinned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ปักหมุด',
                              style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          _formatTime(topic.createdAt),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'โดย ${topic.author}',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        if (topic.isAuthor) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          '${topic.repliesCount} ความคิดเห็น',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        if (topic.likesCount > 0) ...[
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          const SizedBox(width: 6),
                          Row(
                            children: [
                              Icon(
                                topic.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 12,
                                color: topic.isLiked ? Colors.redAccent : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${topic.likesCount}',
                                style: TextStyle(
                                  color: topic.isLiked ? Colors.redAccent : const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}
