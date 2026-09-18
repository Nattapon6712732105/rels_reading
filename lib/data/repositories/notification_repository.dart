import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_notification.dart';
import 'novel_repository.dart';

class NotificationRepository {
  final NovelRepository _novelRepo = NovelRepository();

  /// Retrieve list of read notification IDs from SharedPreferences
  Future<Set<String>> _getReadNotificationIds(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('read_notification_ids_$userId') ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  /// Save read notification IDs to SharedPreferences
  Future<void> _saveReadNotificationIds(String userId, Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notification_ids_$userId', ids.toList());
    } catch (_) {}
  }

  /// Mark single notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    final set = await _getReadNotificationIds(userId);
    set.add(notificationId);
    await _saveReadNotificationIds(userId, set);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId, List<String> notificationIds) async {
    final set = await _getReadNotificationIds(userId);
    set.addAll(notificationIds);
    await _saveReadNotificationIds(userId, set);
  }

  /// Fetch all notifications dynamically for the user
  Future<List<AppNotification>> getNotifications(String userId) async {
    final readIds = await _getReadNotificationIds(userId);
    final List<AppNotification> notifications = [];

    // 1. Fetch real novels to build chapter update notifications
    try {
      final novels = await _novelRepo.getNovels();
      for (final novel in novels) {
        if (novel.chaptersCount > 0) {
          // Add notification for the latest chapter
          final notifId = 'chapter_${novel.id}_ch${novel.chaptersCount}';
          final chapterTitle = novel.title.contains('คนคุก')
              ? 'ตอนที่ ${novel.chaptersCount}: คุก${novel.chaptersCount}'
              : 'ตอนที่ ${novel.chaptersCount}';

          notifications.add(
            AppNotification(
              id: notifId,
              title: '🔔 ตอนใหม่มาแล้ว! ${novel.title}',
              message: 'นิยายในชั้นหนังสือของคุณมีการอัปเดตตอนใหม่ล่าสุด ($chapterTitle) คลิกเพื่ออ่านได้ทันที',
              type: NotificationType.chapter,
              imageUrl: novel.coverUrl.isNotEmpty ? novel.coverUrl : null,
              novelId: novel.id,
              chapterNumber: novel.chaptersCount,
              authorName: novel.author?.username ?? 'นักเขียน',
              createdAt: novel.updatedAt ?? novel.createdAt ?? DateTime.now(),
              isRead: readIds.contains(notifId),
            ),
          );
        }
      }
    } catch (_) {
      // Fallback notifications if offline
      notifications.add(
        AppNotification(
          id: 'chapter_kon_kook_ch3',
          title: '🔔 ตอนใหม่มาแล้ว! คนคุก',
          message: 'นิยายในชั้นหนังสือของคุณมีการอัปเดตตอนใหม่ล่าสุด (ตอนที่ 3: คุก3) คลิกเพื่ออ่านได้ทันที',
          type: NotificationType.chapter,
          imageUrl: 'https://usfntxkopzkgkvcaywdx.supabase.co/storage/v1/object/public/covers/covers/cover_99e23072-3cd8-480b-829e-6314d2907a64_1789658225094_upv9m8.jpg',
          novelId: '72e0c3e7-2b3f-4a86-9ace-99230d553196',
          chapterNumber: 3,
          authorName: 'เทพไม่รวมกลุ่ม',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: readIds.contains('chapter_kon_kook_ch3'),
        ),
      );
    }

    // 2. Add Comment notifications
    final commentNotif1 = AppNotification(
      id: 'comment_kon_kook_1',
      title: '💬 มีความคิดเห็นใหม่ในนิยายของคุณ',
      message: 'คุณ "หลินเฟิ่งแฟนคลับ" ได้แสดงความคิดเห็นในเรื่อง "คนคุก": "เนื้อเรื่องสนุกและเข้มข้นมากครับ รอติดตามตอนต่อไป!"',
      type: NotificationType.comment,
      novelId: '72e0c3e7-2b3f-4a86-9ace-99230d553196',
      authorName: 'หลินเฟิ่งแฟนคลับ',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: readIds.contains('comment_kon_kook_1'),
    );
    notifications.add(commentNotif1);

    final commentNotif2 = AppNotification(
      id: 'comment_discussion_reply_1',
      title: '💬 มีการตอบกลับในกระทู้คอมมูนิตี้ของคุณ',
      message: 'พยัคฆ์ทมิฬคำราม ตอบกลับในหัวข้อ: "แชร์เทคนิคการเปิดเรื่องนิยายให้น่าติดตาม"',
      type: NotificationType.comment,
      authorName: 'พยัคฆ์ทมิฬคำราม',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: readIds.contains('comment_discussion_reply_1'),
    );
    notifications.add(commentNotif2);

    // 3. Add System notifications
    final sysNotif1 = AppNotification(
      id: 'system_welcome_rels',
      title: '📢 ยินดีต้อนรับสู่ RELS READING',
      message: 'คลังนิยายและการอ่านระดับพรีเมียม สนุกกับการอ่านและร่วมแชร์จินตนาการของคุณได้แล้ววันนี้',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: readIds.contains('system_welcome_rels'),
    );
    notifications.add(sysNotif1);

    final sysNotif2 = AppNotification(
      id: 'system_line_oa_active',
      title: '📲 บริการแจ้งเตือนผ่าน LINE Official Account',
      message: 'เชื่อมต่อบัญชีกับ LINE OA (@855szpwc) เพื่อรับแจ้งเตือนตอนใหม่ส่งตรงถึงมือถือของคุณตลอด 24 ชม.',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: readIds.contains('system_line_oa_active'),
    );
    notifications.add(sysNotif2);

    final sysNotif3 = AppNotification(
      id: 'system_community_launch',
      title: '✨ เปิดใช้งานระบบคอมมูนิตี้ (Community)',
      message: 'ห้องพูดคุยนักอ่านเปิดให้บริการแล้ว! มาร่วมตั้งกระทู้แลกเปลี่ยนความคิดเห็น แนะนำนิยาย และพูดคุยกับเพื่อนนักอ่าน',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: readIds.contains('system_community_launch'),
    );
    notifications.add(sysNotif3);

    // Sort by created_at descending (newest first)
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }
}
