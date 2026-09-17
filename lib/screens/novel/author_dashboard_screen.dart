import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/novel_provider.dart';
import '../auth/login_screen.dart';
import 'create_novel_screen.dart';
import 'create_chapter_screen.dart';
import 'novel_detail_screen.dart';

class AuthorDashboardScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AuthorDashboardScreen({super.key, this.onBackToHome});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovelProvider>().fetchNovels();
    });
  }

  List<Novel> _getMyNovels(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.user;
    final allNovels = context.watch<NovelProvider>().allNovels;

    if (currentUser == null) return [];

    return allNovels.where((n) {
      if (currentUser.id.isNotEmpty && (n.authorId == currentUser.id || n.author?.id == currentUser.id)) {
        return true;
      }
      if (currentUser.username.isNotEmpty &&
          n.author?.username.isNotEmpty == true &&
          n.author!.username.trim().toLowerCase() == currentUser.username.trim().toLowerCase()) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final novelProvider = context.watch<NovelProvider>();
    final user = auth.user;
    final myNovels = _getMyNovels(context);

    // Calculate aggregate stats
    int totalChapters = 0;
    for (final n in myNovels) {
      totalChapters += n.chaptersCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard_customize_rounded, color: AppTheme.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'แดชบอร์ดนักเขียน',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'รีเฟรชข้อมูล',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => novelProvider.fetchNovels(),
          ),
          if (auth.isLoggedIn)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
                ).then((_) => novelProvider.fetchNovels());
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('แต่งเรื่องใหม่', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: !auth.isLoggedIn
          ? _buildGuestPrompt(context)
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async => await novelProvider.fetchNovels(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Author Studio Profile & Stats Header
                    _buildAuthorProfileCard(context, user, myNovels.length, totalChapters),

                    const SizedBox(height: 24),

                    // Section Header: My Published Works
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories_rounded, color: AppTheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ผลงานของคุณ (${myNovels.length} เรื่อง)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (myNovels.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
                              ).then((_) => novelProvider.fetchNovels());
                            },
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('แต่งเรื่องใหม่'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Novel List or Empty State
                    if (novelProvider.isLoading && myNovels.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                      )
                    else if (myNovels.isEmpty)
                      _buildEmptyState(context)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: myNovels.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildAuthorNovelCard(context, myNovels[index]);
                        },
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_note_rounded, size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'เข้าสู่ระบบเพื่อใช้งาน Author Studio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'เข้าสู่ระบบเพื่อแต่งนิยาย จัดการตอน และติดตามผลงานของคุณในฐานะนักเขียน',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('เข้าสู่ระบบ / สมัครสมาชิก'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorProfileCard(
    BuildContext context,
    dynamic user,
    int totalNovels,
    int totalChapters,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.18),
            Theme.of(context).cardTheme.color ?? const Color(0xFF16171F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primary,
                backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                    ? Text(
                        user?.username?.isNotEmpty == true
                            ? user!.username![0].toUpperCase()
                            : 'W',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.username ?? 'นักเขียนนิยาย',
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
                            color: AppTheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: AppTheme.secondary),
                              SizedBox(width: 4),
                              Text(
                                'CREATOR',
                                style: TextStyle(
                                  color: AppTheme.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _buildStatItem(context, 'นิยายที่แต่ง', '$totalNovels เรื่อง', Icons.auto_stories_rounded),
              _buildVerticalDivider(context),
              _buildStatItem(context, 'ตอนทั้งหมด', '$totalChapters ตอน', Icons.format_list_numbered_rounded),
              _buildVerticalDivider(context),
              _buildStatItem(context, 'สถานะ', 'เปิดใช้งาน', Icons.check_circle_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.3),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book_outlined, size: 54, color: AppTheme.primary),
          const SizedBox(height: 14),
          const Text(
            'ยังไม่มีผลงานนิยายที่เผยแพร่',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ปลดปล่อยจินตนาการของคุณ สร้างเรื่องราวบทใหม่ แล้วเผยแพร่สู่ชุมชนนักอ่าน Rels Reading วันนี้!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('เริ่มแต่งนิยายเรื่องแรก'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorNovelCard(BuildContext context, Novel novel) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Novel Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 70,
                    height: 98,
                    color: Colors.grey.shade800,
                    child: novel.coverUrl.isNotEmpty
                        ? Image.network(
                            novel.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                          )
                        : const Icon(Icons.book, color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 14),

                // Novel Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${novel.chaptersCount} ตอน',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'เผยแพร่แล้ว',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (novel.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          novel.tags.take(3).join(' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Quick Actions Bar
            Row(
              children: [
                // Add Chapter Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final novelProvider = context.read<NovelProvider>();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateChapterScreen(
                            novelId: novel.id,
                            nextChapterNumber: novel.chaptersCount + 1,
                          ),
                        ),
                      );
                      if (mounted) {
                        novelProvider.fetchNovels();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text('เพิ่มตอนใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // View Details Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NovelDetailScreen(novelId: novel.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('ดูผลงาน'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 6),

                // Edit Button
                IconButton(
                  tooltip: 'แก้ไขข้อมูลนิยาย',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () {
                    _showEditNovelDialog(context, novel);
                  },
                ),

                // Delete Button
                IconButton(
                  tooltip: 'ลบนิยาย',
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                  onPressed: () {
                    _confirmDelete(context, novel);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNovelDialog(BuildContext context, Novel novel) {
    final titleController = TextEditingController(text: novel.title);
    final descController = TextEditingController(text: novel.description);
    final coverController = TextEditingController(text: novel.coverUrl);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('แก้ไขข้อมูลนิยาย'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'ชื่อเรื่อง *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'เรื่องย่อ / คำโปรย'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coverController,
                  decoration: const InputDecoration(labelText: 'URL ภาพปก'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isEmpty) return;

                final auth = context.read<AuthProvider>();
                await context.read<NovelProvider>().updateNovel(
                      id: novel.id,
                      title: newTitle,
                      description: descController.text.trim(),
                      coverUrl: coverController.text.trim(),
                      requesterUserId: auth.user?.id,
                      requesterUsername: auth.user?.username,
                    );

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('อัปเดตข้อมูลนิยายเรียบร้อยแล้ว'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: const Text('บันทึกการแก้ไข'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Novel novel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('ยืนยันการลบนิยาย?'),
          ],
        ),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบนิยายเรื่อง "${novel.title}"? การดำเนินการนี้จะไม่สามารถกู้คืนได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              await context.read<NovelProvider>().deleteNovel(
                    novel.id,
                    requesterUserId: auth.user?.id,
                    requesterUsername: auth.user?.username,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ลบนิยายเรียบร้อยแล้ว')),
                );
              }
            },
            child: const Text('ยืนยันการลบ'),
          ),
        ],
      ),
    );
  }
}
