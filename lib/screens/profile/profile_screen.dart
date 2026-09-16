import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reader_settings_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

              // Backend Info Card
              const Text(
                'ข้อมูลเซิร์ฟเวอร์ Backend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('URL Backend API', style: TextStyle(fontSize: 13)),
                          Text(
                            AppConfig.baseUrl,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('สถานะการเชื่อมต่อ', style: TextStyle(fontSize: 13)),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: auth.backendOnline ? AppTheme.success : AppTheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                auth.backendOnline ? 'เชื่อมต่อแล้ว (Online)' : 'สำรองข้อมูลจำลอง',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: auth.backendOnline ? AppTheme.success : AppTheme.secondary,
                                ),
                              ),
                            ],
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
                      trailing: Text(
                        '${settings.fontSize.toInt()} px',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined, color: AppTheme.secondary),
                      title: const Text('ธีมการอ่านเริ่มต้น', style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        settings.themeMode.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
    final auth = context.read<AuthProvider>();
    final lineIdController = TextEditingController(text: auth.lineUserId ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.link_rounded, color: Color(0xFF06C755), size: 24),
              SizedBox(width: 8),
              Text('ผูกบัญชี LINE', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'กรอก LINE User ID ของคุณ (ขึ้นต้นด้วย U ตามด้วยตัวเลขและตัวอักษร) เพื่อรับข้อความแจ้งเตือน Flex Message เมื่อมีตอนใหม่',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lineIdController,
                decoration: const InputDecoration(
                  labelText: 'LINE User ID',
                  hintText: 'Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  lineIdController.text = 'U${DateTime.now().millisecondsSinceEpoch}sample';
                },
                icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                label: const Text('ใส่ ID จำลองสำหรับการทดสอบ', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06C755),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final id = lineIdController.text.trim();
                if (id.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอก LINE User ID')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final ok = await auth.linkLineAccount(id);
                if (context.mounted) {
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ผูกบัญชี LINE สำเร็จแล้ว! พร้อมรับการแจ้งเตือนตอนใหม่'),
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
              },
              child: const Text('ยืนยันผูกบัญชี'),
            ),
          ],
        );
      },
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
                '1. แอดเพื่อน LINE Official Account (@rels_reading)\n'
                '2. ดู LINE User ID ของคุณ หรือใช้ Rich Menu ในห้องแชท\n'
                '3. นำ LINE User ID มาผูกในหน้านี้\n'
                '4. เมื่อนักเขียนลงตอนใหม่ของนิยายที่คุณ Bookmark ไว้ ระบบจะส่งการ์ด Flex Message แจ้งเตือนเข้าแชท LINE ของคุณทันที!',
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
}
