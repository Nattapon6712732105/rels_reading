import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/novel_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../reader/reader_screen.dart';
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
          // Collapsible Image AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
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
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (novel != null)
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isSaved ? AppTheme.secondary : Colors.white,
                  ),
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
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          '${chapters.length} ตอน',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                          label: const Text('เริ่มอ่านเลย'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : 'ไม่มีเนื้อหาเรื่องย่อระบุไว้',
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
                          );
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

          // Chapter List
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              ),
            )
          else if (chapters.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('ยังไม่มีตอนที่เผยแพร่ เป็นคนแรกที่เริ่มเขียนตอนใหม่!'),
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

  Widget _buildPlaceholderBg() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Icons.auto_stories, size: 64, color: Color(0xFF475569)),
      ),
    );
  }
}
