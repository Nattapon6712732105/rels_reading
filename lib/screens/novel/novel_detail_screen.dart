import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/novel.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/novel_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../reader/reader_screen.dart';
import '../main_nav_screen.dart';
import 'create_chapter_screen.dart';

class NovelDetailScreen extends StatefulWidget {
  final String novelId;

  const NovelDetailScreen({super.key, required this.novelId});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovelProvider>().loadNovelDetails(widget.novelId);
    });
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 0)),
      );
    }
  }

  bool _checkIsAuthor(Novel? novel, User? currentUser) {
    if (novel == null || currentUser == null) return false;

    // Direct ID match
    if (currentUser.id.isNotEmpty) {
      if (novel.authorId == currentUser.id) return true;
      if (novel.author?.id == currentUser.id) return true;
    }

    // Username match
    if (currentUser.username.isNotEmpty && novel.author?.username.isNotEmpty == true) {
      if (currentUser.username.trim().toLowerCase() == novel.author!.username.trim().toLowerCase()) {
        return true;
      }
    }

    return false;
  }


  void _showReportDialog(Novel novel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag_outlined, color: AppTheme.warning),
            SizedBox(width: 8),
            Text('รายงานนิยาย'),
          ],
        ),
        content: Text('คุณต้องการรายงานนิยายเรื่อง "${novel.title}" เกี่ยวกับการละเมิดลิขสิทธิ์หรือเนื้อหาที่ไม่เหมาะสมใช่หรือไม่? ทีมงานจะดำเนินการตรวจสอบทันที'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งรายงานให้ทีมงานตรวจสอบเรียบร้อยแล้ว ขอบคุณที่ร่วมสร้างสังคมนักอ่านที่ดี'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: const Text('ส่งรายงาน'),
          ),
        ],
      ),
    );
  }

  void _showNovelOptionsSheet(Novel novel) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.user;
    final isAuthor = _checkIsAuthor(novel, currentUser);
    final bookmarkProvider = context.read<BookmarkProvider>();
    final isSaved = bookmarkProvider.isBookmarked(novel.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isAuthor ? Icons.verified_user_rounded : Icons.menu_book_rounded,
                        size: 16,
                        color: isAuthor ? AppTheme.primary : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAuthor ? 'เมนูจัดการสำหรับนักเขียน (เจ้าของผลงาน)' : 'ตัวเลือกสำหรับนักอ่าน',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAuthor ? AppTheme.primary : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Author Only Options
                if (isAuthor) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_note_rounded, color: AppTheme.primary),
                    title: const Text('แก้ไขข้อมูลนิยาย (ชื่อ/เรื่องย่อ/ปก)'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showEditNovelSheet(novel);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.secondary),
                    title: const Text('แต่งตอนใหม่'),
                    onTap: () {
                      Navigator.pop(ctx);
                      final chapters = context.read<NovelProvider>().currentChapters;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateChapterScreen(
                            novelId: novel.id,
                            nextChapterNumber: chapters.length + 1,
                          ),
                        ),
                      ).then((_) {
                        if (mounted) {
                          context.read<NovelProvider>().loadNovelDetails(widget.novelId);
                        }
                      });
                    },
                  ),
                ],

                // Bookmark for Everyone
                ListTile(
                  leading: Icon(
                    isSaved ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
                    color: isSaved ? AppTheme.error : AppTheme.secondary,
                  ),
                  title: Text(isSaved ? 'ลบออกจากชั้นหนังสือ' : 'เพิ่มเข้าชั้นหนังสือ'),
                  onTap: () {
                    Navigator.pop(ctx);
                    bookmarkProvider.toggleBookmark(novel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isSaved ? 'ลบออกจากชั้นหนังสือแล้ว' : 'เพิ่มเข้าชั้นหนังสือแล้ว'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // Share
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('แชร์นิยายเรื่องนี้'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('คัดลอกลิงก์นิยายแล้ว พร้อมแชร์ให้เพื่อนๆ อ่าน'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // Reader Only: Report
                if (!isAuthor)
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: AppTheme.warning),
                    title: const Text('รายงานนิยายที่ไม่เหมาะสม'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showReportDialog(novel);
                    },
                  ),

                // Author Only: Delete Novel
                if (isAuthor) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                    title: const Text('ลบนิยายเรื่องนี้', style: TextStyle(color: AppTheme.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDeleteNovel(novel);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNovelSheet(Novel novel) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.user;
    if (!_checkIsAuthor(novel, currentUser)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('คุณไม่มีสิทธิ์แก้ไขนิยายเรื่องนี้ (สงวนสิทธิ์เฉพาะเจ้าของผลงาน)'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final titleController = TextEditingController(text: novel.title);
    final descController = TextEditingController(text: novel.description);
    final coverController = TextEditingController(text: novel.coverUrl);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'แก้ไขข้อมูลนิยาย',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อเรื่องนิยาย *',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'เรื่องย่อ / คำโปรย',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: coverController,
                      decoration: const InputDecoration(
                        labelText: 'ลิงก์ภาพปก (Image URL)',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final newTitle = titleController.text.trim();
                              if (newTitle.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('กรุณาระบุชื่อเรื่อง')),
                                );
                                return;
                              }

                              setSheetState(() => isSaving = true);

                              try {
                                await context.read<NovelProvider>().updateNovel(
                                  id: novel.id,
                                  title: newTitle,
                                  description: descController.text.trim(),
                                  coverUrl: coverController.text.trim(),
                                  requesterUserId: currentUser?.id,
                                  requesterUsername: currentUser?.username,
                                );

                                if (mounted && ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('บันทึกการแก้ไขนิยายสำเร็จ!'),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                  setState(() {});
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('เกิดข้อผิดพลาด: $e'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setSheetState(() => isSaving = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('บันทึกการแก้ไข'),
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

  void _confirmDeleteNovel(Novel novel) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.user;
    if (!_checkIsAuthor(novel, currentUser)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('คุณไม่มีสิทธิ์ลบนิยายของผู้อื่น (สงวนสิทธิ์เฉพาะเจ้าของผลงาน)'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

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
        content: Text(
          'คุณกำลังจะลบนิยายเรื่อง "${novel.title}"\n\nการกระทำนี้จะลบข้อมูลและทุกตอนอย่างถาวร ไม่สามารถกู้คืนได้ และสงวนสิทธิ์เฉพาะคุณในฐานะผู้แต่งเท่านั้น',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<NovelProvider>().deleteNovel(
                  novel.id,
                  requesterUserId: currentUser?.id,
                  requesterUsername: currentUser?.username,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ลบนิยายของคุณเรียบร้อยแล้ว'),
                      backgroundColor: AppTheme.secondary,
                    ),
                  );
                  _handleBack();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('ยืนยันลบนิยาย'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final authProvider = context.watch<AuthProvider>();

    final novel = novelProvider.currentNovel;
    final chapters = novelProvider.currentChapters;
    final isLoading = novelProvider.isLoadingChapters;
    final isAuthor = _checkIsAuthor(novel, authProvider.user);

    if (novel == null && isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final isSaved = novel != null && bookmarkProvider.isBookmarked(novel.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Full-bleed Cover Hero AppBar
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF0B0F19),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              tooltip: 'ย้อนกลับ',
              onPressed: _handleBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Full bleed cover image
                  if (novel?.coverUrl.isNotEmpty == true)
                    Image.network(
                      novel!.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderBg(),
                    )
                  else
                    _buildPlaceholderBg(),
                  // Gradient overlay: transparent top → opaque bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (novel != null) ...[
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: isSaved ? AppTheme.secondary : Colors.white,
                      size: 20,
                    ),
                  ),
                  tooltip: isSaved ? 'ลบออกจากชั้น' : 'บันทึกเข้าชั้น',
                  onPressed: () {
                    bookmarkProvider.toggleBookmark(novel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSaved ? 'ลบออกจากชั้นหนังสือแล้ว' : 'เพิ่มเข้าชั้นหนังสือแล้ว',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                  ),
                  tooltip: 'ตัวเลือกเพิ่มเติม',
                  onPressed: () => _showNovelOptionsSheet(novel),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    novel?.title ?? 'กำลังโหลด...',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author & Stats
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.person, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        novel?.displayAuthorName ?? 'นักเขียน',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (isAuthor) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, size: 10, color: AppTheme.primary),
                              SizedBox(width: 3),
                              Text(
                                'ผลงานของคุณ',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 14, color: AppTheme.secondary),
                            const SizedBox(width: 6),
                            Text(
                              '${chapters.length} ตอน',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (novel?.tags.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: novel!.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                          ),
                          child: Text(
                            tag.startsWith('#') ? tag : '#$tag',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Action Buttons Row

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: chapters.isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReaderScreen(
                                        novel: novel!,
                                        chapter: chapters.first,
                                        allChapters: chapters,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('เริ่มอ่านตอนแรก'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (novel != null) {
                            bookmarkProvider.toggleBookmark(novel);
                          }
                        },
                        icon: Icon(
                          isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                          color: isSaved ? AppTheme.secondary : null,
                        ),
                        label: Text(isSaved ? 'บันทึกแล้ว' : 'เก็บเข้าชั้น'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Synopsis / Description
                  const Text(
                    'เรื่องย่อ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    novel?.description.isNotEmpty == true
                        ? novel!.description
                        : 'ยังไม่มีเรื่องย่อระบุไว้สำหรับนิยายเรื่องนี้',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Chapters Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'รายชื่อตอน (${chapters.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (isAuthor)
                        TextButton.icon(
                          onPressed: () async {
                            if (novel == null) return;
                            final novelProv = context.read<NovelProvider>();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateChapterScreen(
                                  novelId: novel.id,
                                  nextChapterNumber: chapters.length + 1,
                                ),
                              ),
                            );
                            if (mounted) {
                              novelProv.loadNovelDetails(widget.novelId);
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('แต่งตอนใหม่'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Chapter List (ListView)
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              ),
            )
          else if (chapters.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.edit_document, size: 48, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'ยังไม่มีตอนที่เผยแพร่',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (isAuthor) ...[
                        Text(
                          'กดปุ่มด้านล่างเพื่อเริ่มเขียนตอนแรกของนิยายเรื่องนี้',
                          style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (novel == null) return;
                            final novelProv = context.read<NovelProvider>();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateChapterScreen(
                                  novelId: novel.id,
                                  nextChapterNumber: 1,
                                ),
                              ),
                            );
                            if (mounted) {
                              novelProv.loadNovelDetails(widget.novelId);
                            }
                          },
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('แต่งตอนที่ 1 ทันที'),
                        ),
                      ] else ...[
                        Text(
                          'นิยายเรื่องนี้ยังไม่มีตอนที่เผยแพร่\nรอติดตามตอนต่อไปจากนักเขียน',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.8)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ch = chapters[index];
                    final isFirst = index == 0;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(
                              novel: novel!,
                              chapter: ch,
                              allChapters: chapters,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isFirst
                              ? AppTheme.primary.withOpacity(0.08)
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFirst
                                ? AppTheme.primary.withOpacity(0.3)
                                : Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Episode number box
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isFirst
                                    ? AppTheme.primary
                                    : AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${ch.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isFirst ? Colors.white : AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ch.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isFirst ? AppTheme.primary : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _formatDate(ch.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!authProvider.isLoggedIn && ch.chapterNumber > 5)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withOpacity(0.35)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline_rounded, size: 12, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'สมาชิก',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 22,
                                color: isFirst ? AppTheme.primary : Colors.grey.withOpacity(0.5),
                              ),
                          ],
                        ),
                      ),
                    );

                  },
                  childCount: chapters.length,
                ),
              ),
            ),
        ],
      ),
      // Sticky bottom CTA
      bottomNavigationBar: novel != null && chapters.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen(
                                novel: novel,
                                chapter: chapters.first,
                                allChapters: chapters,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('อ่านตั้งแต่ต้น', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => bookmarkProvider.toggleBookmark(novel),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: isSaved ? AppTheme.secondary : AppTheme.primary),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                        color: isSaved ? AppTheme.secondary : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'เร็วๆ นี้';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPlaceholderBg() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Icons.auto_stories, size: 64, color: Color(0xFF475569)),
      ),
    );
  }
}
