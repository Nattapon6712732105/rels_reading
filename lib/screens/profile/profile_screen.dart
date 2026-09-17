import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/local_novel_storage.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reader_settings_provider.dart';
import '../../providers/novel_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../auth/login_screen.dart';
import '../auth/widgets/pdpa_consent_sheet.dart';
import '../novel/novel_detail_screen.dart';
import '../novel/create_novel_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pdpaAccepted = false;

  @override
  void initState() {
    super.initState();
    _checkPdpaStatus();
  }

  Future<void> _checkPdpaStatus() async {
    final accepted = await LocalNovelStorage.isConsentAccepted();
    if (mounted) {
      setState(() {
        _pdpaAccepted = accepted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<ReaderSettingsProvider>();
    final user = auth.user;


    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์และการตั้งค่า'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: auth.isLoggedIn
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: AppTheme.primary,
                              backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                                  ? Text(
                                      user?.username.isNotEmpty == true
                                          ? user!.username[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user?.username ?? 'ผู้ใช้',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          user?.role.toUpperCase() ?? 'USER',
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: user?.isGoogleAuth == true
                                              ? const Color(0xFF4285F4).withOpacity(0.15)
                                              : Colors.grey.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          user?.isGoogleAuth == true ? 'GOOGLE' : 'EMAIL',
                                          style: TextStyle(
                                            color: user?.isGoogleAuth == true
                                                ? const Color(0xFF4285F4)
                                                : Colors.grey,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _showEditProfileDialog(context),
                                    child: const Text(
                                      'แก้ไขข้อมูลส่วนตัว',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const Icon(Icons.account_circle_outlined, size: 64, color: AppTheme.primary),
                            const SizedBox(height: 12),
                            const Text(
                              'ยังไม่ได้เข้าสู่ระบบ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'เข้าสู่ระบบเพื่อซิงก์ข้อมูลชั้นหนังสือและความคิดเห็น',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text('เข้าสู่ระบบ / สมัครสมาชิก'),
                            ),
                          ],
                        ),
                ),
              ),

              // Reading & Authoring Stats Grid (ใช้ Grid View)
              const SizedBox(height: 18),
              _buildStatsGrid(context),

              const SizedBox(height: 24),

              // LINE Official Account Section
              const Text(
                'การแจ้งเตือนผ่าน LINE Official Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF06C755).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Color(0xFF06C755),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'LINE OA Notifications',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  auth.isLineLinked
                                      ? 'ผูกบัญชีแล้ว (รับ Flex Message ตอนใหม่)'
                                      : 'ยังไม่ได้ผูกบัญชี LINE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: auth.isLineLinked
                                        ? const Color(0xFF06C755)
                                        : AppTheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (auth.isLineLinked
                                      ? const Color(0xFF06C755)
                                      : AppTheme.secondary)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              auth.isLineLinked ? 'LINKED' : 'NOT LINKED',
                              style: TextStyle(
                                color: auth.isLineLinked
                                    ? const Color(0xFF06C755)
                                    : AppTheme.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'รับการแจ้งเตือนทันทีผ่านการ์ด Flex Message เมื่อนิยายเรื่องที่คุณ Bookmark ไว้มีการลงตอนใหม่ พร้อมรูปปกและปุ่มกดอ่านได้ทันที',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
                          height: 1.4,
                        ),
                      ),
                      if (auth.isLineLinked && auth.lineUserId != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.perm_identity_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'LINE ID: ${auth.lineUserId}',
                                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (!auth.isLineLinked)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: auth.isLoggedIn
                                    ? () => _showLinkLineDialog(context)
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนผูกบัญชี LINE')),
                                        );
                                      },
                                icon: const Icon(Icons.link_rounded, size: 18),
                                label: const Text('ผูกบัญชี LINE ตอนนี้'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF06C755),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _handleUnlinkLine(context),
                                icon: const Icon(Icons.link_off_rounded, size: 18, color: AppTheme.error),
                                label: const Text('ยกเลิกการผูกบัญชี LINE', style: TextStyle(color: AppTheme.error)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.error),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            tooltip: 'คำแนะนำ LINE Official Account',
                            onPressed: () => _showLineInfoDialog(context),
                            icon: const Icon(Icons.help_outline_rounded, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),



              // Reading Preferences
              const Text(
                'การตั้งค่าการอ่านเริ่มต้น',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.format_size_rounded, color: AppTheme.primary),
                      title: const Text('ขนาดตัวอักษรเริ่มต้น', style: TextStyle(fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${settings.fontSize.toInt()} px',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                        ],
                      ),
                      onTap: () => _showFontSizeSettingsSheet(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined, color: AppTheme.secondary),
                      title: const Text('ธีมการอ่านเริ่มต้น', style: TextStyle(fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            settings.themeMode.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                        ],
                      ),
                      onTap: () => _showThemeSettingsSheet(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        _pdpaAccepted ? Icons.privacy_tip_outlined : Icons.warning_amber_rounded,
                        color: _pdpaAccepted ? AppTheme.primary : Colors.amber,
                      ),
                      title: const Text('นโยบาย PDPA และกฎหมายลิขสิทธิ์', style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        _pdpaAccepted ? 'ตรวจสอบสิทธิและความคุ้มครองผลงาน (ยินยอมแล้ว)' : 'กรุณาตรวจสอบและยินยอมสิทธิและความคุ้มครอง (ยังไม่ยินยอม)',
                        style: TextStyle(fontSize: 12, color: _pdpaAccepted ? null : Colors.amber),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (_pdpaAccepted ? const Color(0xFF06C755) : Colors.amber).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _pdpaAccepted ? 'ยินยอมแล้ว' : 'ยังไม่ยินยอม',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _pdpaAccepted ? const Color(0xFF06C755) : Colors.amber,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                        ],
                      ),
                      onTap: () async {
                        await PdpaConsentSheet.show(
                          context,
                          onAccepted: () async {
                            final accepted = await LocalNovelStorage.isConsentAccepted();
                            if (mounted) setState(() => _pdpaAccepted = accepted);
                          },
                        );
                        final accepted = await LocalNovelStorage.isConsentAccepted();
                        if (mounted) setState(() => _pdpaAccepted = accepted);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'เกี่ยวกับแอปพลิเคชัน & ชุมชน',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.forum_outlined, color: Color(0xFF5865F2)),
                      title: const Text('เข้าร่วม Discord Rels Reading Community', style: TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => launchUrlString('https://discord.gg/relsreading'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language_rounded, color: Color(0xFF1877F2)),
                      title: const Text('เข้าร่วม Facebook Community', style: TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => launchUrlString('https://facebook.com/relsreading'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Logout Button (if logged in)
              if (auth.isLoggedIn)
                OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ออกจากระบบแล้ว')),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  label: const Text('ออกจากระบบ', style: TextStyle(color: AppTheme.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final usernameController = TextEditingController(text: auth.user?.username);
    final emailController = TextEditingController(text: auth.user?.email);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('แก้ไขโปรไฟล์'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'อีเมล'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.updateProfile(
                  username: usernameController.text.trim(),
                  email: emailController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  void _showLinkLineDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _LineLinkDialog(),
    );
  }

  void _handleUnlinkLine(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('ยืนยันยกเลิกการผูก LINE?'),
          content: const Text('หากยกเลิก คุณจะไม่ได้รับการแจ้งเตือนตอนใหม่ผ่านแชท LINE อีกต่อไป'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ย้อนกลับ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () async {
                Navigator.pop(ctx);
                final auth = context.read<AuthProvider>();
                final ok = await auth.unlinkLineAccount();
                if (context.mounted) {
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ยกเลิกการผูกบัญชี LINE เรียบร้อยแล้ว')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(auth.errorMessage ?? 'ยกเลิกการผูกบัญชีไม่สำเร็จ'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('ยืนยันยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  void _showLineInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Color(0xFF06C755), size: 24),
              SizedBox(width: 8),
              Text('วิธีรับแจ้งเตือนผ่าน LINE', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '1. แอดเพื่อน LINE Official Account (@855szpwc) ด้วย QR Code\n'
                '2. กดปุ่ม "ผูกบัญชี LINE" แล้วนำรหัส 6 หลักที่ระบบสร้างให้ ส่งเข้าไปในห้องแชท LINE\n'
                '3. ระบบจะทำการตรวจสอบและผูกบัญชีกับ LINE ของคุณทันทีโดยอัตโนมัติ!\n'
                '4. เมื่อนักเขียนอัปเดตตอนใหม่ของนิยายที่คุณ Bookmark ไว้ ระบบจะส่งการ์ด Flex Message แจ้งเตือนเข้าแชท LINE ทันที',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('เข้าใจแล้ว'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final bookmarks = context.watch<BookmarkProvider>().bookmarks;
    final novels = context.watch<NovelProvider>().allNovels;
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.user;

    final myNovelsList = novels.where((n) {
      if (currentUser == null) return false;
      if (currentUser.id.isNotEmpty && (n.authorId == currentUser.id || n.author?.id == currentUser.id)) {
        return true;
      }
      if (currentUser.username.isNotEmpty && n.author?.username.isNotEmpty == true &&
          n.author!.username.trim().toLowerCase() == currentUser.username.trim().toLowerCase()) {
        return true;
      }
      return false;
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildStatCard(
              context,
              icon: Icons.bookmark_added_rounded,
              color: AppTheme.secondary,
              title: 'ชั้นหนังสือ',
              value: '${bookmarks.length} เรื่อง',
            );
          case 1:
            return _buildStatCard(
              context,
              icon: Icons.edit_note_rounded,
              color: AppTheme.primary,
              title: 'ผลงานที่แต่ง',
              value: '${myNovelsList.length} เรื่อง',
              onTap: auth.isLoggedIn
                  ? () => _showMyNovelsSheet(context, myNovelsList)
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อดูผลงานที่คุณแต่ง')),
                      );
                    },
            );
          case 2:
            return _buildStatCard(
              context,
              icon: Icons.auto_stories_rounded,
              color: const Color(0xFF06C755),
              title: 'คลังนิยายระบบ',
              value: '${novels.length} เรื่อง',
            );
          case 3:
          default:
            return _buildStatCard(
              context,
              icon: _pdpaAccepted ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
              color: _pdpaAccepted ? const Color(0xFF06C755) : Colors.amber,
              title: 'สถานะ PDPA',
              value: _pdpaAccepted ? 'ยินยอมแล้ว' : 'ยังไม่ยินยอม',
              onTap: () async {
                await PdpaConsentSheet.show(
                  context,
                  onAccepted: () async {
                    final accepted = await LocalNovelStorage.isConsentAccepted();
                    if (mounted) setState(() => _pdpaAccepted = accepted);
                  },
                );
                final accepted = await LocalNovelStorage.isConsentAccepted();
                if (mounted) setState(() => _pdpaAccepted = accepted);
              },
            );
        }
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: onTap != null ? color : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSettingsSheet(BuildContext context, ReaderSettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentSize = settings.fontSize;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.format_size_rounded, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'ขนาดตัวอักษรเริ่มต้น',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${currentSize.toInt()} px',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Live preview box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: settings.backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        'ตัวอย่างขนาดตัวอักษรสำหรับการอ่านนิยาย สามารถปรับให้พอดีกับสายตาของคุณได้ตลอดเวลา',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: currentSize,
                          color: settings.textColor,
                          height: settings.lineHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: currentSize > 14
                              ? () {
                                  final newSize = currentSize - 1;
                                  settings.setFontSize(newSize);
                                  setSheetState(() {});
                                }
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        Expanded(
                          child: Slider(
                            value: currentSize,
                            min: 14.0,
                            max: 30.0,
                            divisions: 16,
                            label: '${currentSize.toInt()} px',
                            activeColor: AppTheme.primary,
                            onChanged: (val) {
                              settings.setFontSize(val);
                              setSheetState(() {});
                            },
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: currentSize < 30
                              ? () {
                                  final newSize = currentSize + 1;
                                  settings.setFontSize(newSize);
                                  setSheetState(() {});
                                }
                              : null,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeSettingsSheet(BuildContext context, ReaderSettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.palette_outlined, color: AppTheme.secondary),
                    SizedBox(width: 8),
                    Text(
                      'ธีมการอ่านเริ่มต้น',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _buildThemeChoice(
                      context,
                      settings: settings,
                      title: 'โหมดมืด (Dark)',
                      mode: ReaderThemeMode.dark,
                      bgColor: AppTheme.readerDarkBg,
                      textColor: AppTheme.readerDarkText,
                    ),
                    const SizedBox(width: 10),
                    _buildThemeChoice(
                      context,
                      settings: settings,
                      title: 'ถนอมสายตา (Sepia)',
                      mode: ReaderThemeMode.sepia,
                      bgColor: AppTheme.readerSepiaBg,
                      textColor: AppTheme.readerSepiaText,
                    ),
                    const SizedBox(width: 10),
                    _buildThemeChoice(
                      context,
                      settings: settings,
                      title: 'โหมดสว่าง (Light)',
                      mode: ReaderThemeMode.light,
                      bgColor: AppTheme.readerLightBg,
                      textColor: AppTheme.readerLightText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeChoice(
    BuildContext context, {
    required ReaderSettingsProvider settings,
    required String title,
    required ReaderThemeMode mode,
    required Color bgColor,
    required Color textColor,
  }) {
    final isSelected = settings.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          settings.setThemeMode(mode);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aa',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor),
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMyNovelsSheet(BuildContext context, List<Novel> myNovels) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note_rounded, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'ผลงานที่คุณแต่ง (${myNovels.length} เรื่อง)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('แต่งเรื่องใหม่'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: myNovels.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.menu_book_rounded, size: 56, color: Colors.grey.withOpacity(0.5)),
                                const SizedBox(height: 12),
                                const Text(
                                  'ยังไม่มีผลงานที่คุณแต่งในบัญชีนี้',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'สร้างผลงานเรื่องแรกของคุณเพื่อเริ่มแชร์เรื่องราวให้นักอ่านทั่วประเทศ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: myNovels.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final novel = myNovels[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: novel.coverUrl.isNotEmpty
                                    ? Image.network(
                                        novel.coverUrl,
                                        width: 48,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 48,
                                          height: 64,
                                          color: AppTheme.primary.withOpacity(0.2),
                                          child: const Icon(Icons.book, color: AppTheme.primary),
                                        ),
                                      )
                                    : Container(
                                        width: 48,
                                        height: 64,
                                        color: AppTheme.primary.withOpacity(0.2),
                                        child: const Icon(Icons.book, color: AppTheme.primary),
                                      ),
                              ),
                              title: Text(
                                novel.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${novel.chaptersCount} ตอน • ${novel.tags.isNotEmpty ? novel.tags.take(2).join(" ") : "ไม่มีแท็ก"}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novel.id)),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}



class _LineLinkDialog extends StatefulWidget {
  const _LineLinkDialog();

  @override
  State<_LineLinkDialog> createState() => _LineLinkDialogState();
}

class _LineLinkDialogState extends State<_LineLinkDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _linkCode;
  String? _qrCodeUrl;
  String? _addFriendUrl;
  String? _botBasicId;
  bool _isChecking = false;
  bool _showManualInput = false;
  final _manualIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLinkData();
  }

  @override
  void dispose() {
    _manualIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchLinkData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final oaInfo = await auth.getLineOaInfo();
      final codeRes = await auth.createLineLinkCode();

      if (mounted) {
        setState(() {
          _botBasicId = oaInfo['botBasicId'] ?? '@855szpwc';
          _addFriendUrl = oaInfo['addFriendUrl'] ?? 'https://line.me/R/ti/p/@855szpwc';
          _qrCodeUrl = oaInfo['qrCodeUrl'] ??
              'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://line.me/R/ti/p/@855szpwc';
          _linkCode = codeRes['code'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    final auth = context.read<AuthProvider>();
    await auth.fetchLineStatus();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (auth.isLineLinked) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ผูกบัญชี LINE สำเร็จแล้ว! พร้อมรับการแจ้งเตือนตอนใหม่'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ยังไม่พบข้อความยืนยันจาก LINE กรุณาส่งรหัส 6 หลักในแชทก่อน แล้วกดตรวจอีกครั้ง'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }

  Future<void> _openLineApp() async {
    final url = _addFriendUrl ?? 'https://line.me/R/ti/p/@855szpwc';
    try {
      final canLaunch = await canLaunchUrlString(url);
      if (canLaunch) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrlString(url);
      }
    } catch (_) {
      await launchUrlString(url);
    }
  }

  Future<void> _copyLinkCode() async {
    if (_linkCode == null) return;
    await Clipboard.setData(ClipboardData(text: _linkCode!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('คัดลอกรหัส $_linkCode เรียบร้อยแล้ว! นำไปส่งในแชท LINE ได้เลย'),
          backgroundColor: const Color(0xFF06C755),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _submitManualId() async {
    final manualId = _manualIdController.text.trim();
    if (manualId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก LINE User ID')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.linkLineAccount(manualId);
    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ผูกบัญชี LINE สำเร็จเรียบร้อยแล้ว'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'ผูกบัญชี LINE ไม่สำเร็จ'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06C755).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF06C755), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ผูกบัญชี LINE Official',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'เพื่อรับการแจ้งเตือนตอนใหม่ผ่านแชท',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF06C755)),
                        SizedBox(height: 16),
                        Text('กำลังเตรียม QR Code และรหัสเชื่อมต่อ...', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppTheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchLinkData,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('ลองใหม่อีกครั้ง'),
                      ),
                    ],
                  ),
                )
              else ...[
                // Step 1: Add Friend via QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06C755),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ขั้นตอนที่ 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'สแกน QR เพิ่มเพื่อน LINE',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // QR Code Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _qrCodeUrl!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 160,
                              height: 160,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _openLineApp,
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text('เปิดแอป LINE เพื่อเพิ่มเพื่อน (${_botBasicId ?? "@855szpwc"})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06C755),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Step 2: Send 6-digit link code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ขั้นตอนที่ 2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'ส่งรหัสนี้ในห้องแชท LINE',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Code Display Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06C755).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF06C755).withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _linkCode ?? '------',
                              style: const TextStyle(
                                fontSize: 30,
                                letterSpacing: 6,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF06C755),
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _copyLinkCode,
                              icon: const Icon(Icons.copy_rounded, color: Color(0xFF06C755)),
                              tooltip: 'คัดลอกรหัส',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('รหัสมีอายุ 15 นาที', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _fetchLinkData,
                            child: const Text(
                              'สร้างรหัสใหม่',
                              style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Check Status Action Button
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.verified_outlined, size: 18),
                  label: const Text(
                    'ตรวจสอบสถานะการผูกบัญชี',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

                const SizedBox(height: 10),

                // Manual ID Accordion Fallback
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _showManualInput = !_showManualInput);
                    },
                    child: Text(
                      _showManualInput ? 'ซ่อนการระบุ ID ด้วยตนเอง' : 'หรือระบุ LINE User ID ด้วยตนเอง',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),

                if (_showManualInput) ...[
                  const SizedBox(height: 6),
                  TextField(
                    controller: _manualIdController,
                    decoration: InputDecoration(
                      labelText: 'LINE User ID (ขึ้นต้นด้วย U)',
                      hintText: 'Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                      isDense: true,
                      suffixIcon: IconButton(
                        onPressed: _submitManualId,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        tooltip: 'ผูกบัญชี',
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

