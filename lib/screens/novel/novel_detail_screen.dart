import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/novel.dart';
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

  void _showNovelOptionsSheet(Novel novel) {
    final bookmarkProvider = context.read<BookmarkProvider>();
    final isSaved = bookmarkProvider.isBookmarked(novel.id);

    showModalBottomSheet(
      context: context,
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
            ),
          ),
        );
      },
    );
  }

  void _showEditNovelSheet(Novel novel) {
    final titleController = TextEditingController(text: novel.title);
    final descController = TextEditingController(text: novel.description);
    final coverController = TextEditingController(text: novel.coverUrl);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                                );

                                if (mounted) {
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบนิยาย?'),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบนิยายเรื่อง "${novel.title}" ข้อมูลทั้งหมดรวมถึงตอนจะไม่สามารถกู้คืนได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<NovelProvider>().deleteNovel(novel.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ลบนิยายเรียบร้อยแล้ว'),
                    backgroundColor: AppTheme.secondary,
                  ),
                );
                _handleBack();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('ลบนิยาย'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();

    final novel = novelProvider.currentNovel;
    final chapters = novelProvider.currentChapters;
    final isLoading = novelProvider.isLoadingChapters;

    if (novel == null && isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final isSaved = novel != null && bookmarkProvider.isBookmarked(novel.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Image AppBar with Guaranteed Back Button & Options
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (novel?.coverUrl.isNotEmpty == true)
                    Image.network(
                      novel!.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderBg(),
                    )
                  else
                    _buildPlaceholderBg(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.2, 0.65, 1.0],
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
                      TextButton.icon(
                        onPressed: () {
                          if (novel == null) return;
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
                      Text(
                        'กดปุ่มด้านล่างเพื่อเริ่มเขียนตอนแรกของนิยายเรื่องนี้',
                        style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (novel == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateChapterScreen(
                                novelId: novel.id,
                                nextChapterNumber: 1,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              context.read<NovelProvider>().loadNovelDetails(widget.novelId);
                            }
                          });
                        },
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('แต่งตอนที่ 1 ทันที'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ch = chapters[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(0.12),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.12),
                          child: Text(
                            '${ch.chapterNumber}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          ch.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          'เผยแพร่เมื่อ ${_formatDate(ch.createdAt)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
                      ),
                    );
                  },
                  childCount: chapters.length,
                ),
              ),
            ),
        ],
      ),
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
