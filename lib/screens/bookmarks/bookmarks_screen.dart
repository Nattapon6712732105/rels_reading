import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/novel.dart';
import '../../providers/bookmark_provider.dart';
import '../novel/novel_detail_screen.dart';
import '../main_nav_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool _isGridView = true;
  String _sortBy = 'latest'; // 'latest', 'title'

  void _showShelfOptionsSheet(BuildContext context) {
    final bookmarkProvider = context.read<BookmarkProvider>();

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
                const Text(
                  'จัดเรียงและจัดการชั้นหนังสือ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded, color: AppTheme.primary),
                  title: const Text('เรียงตามที่เพิ่มล่าสุด'),
                  trailing: _sortBy == 'latest'
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = 'latest');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha_rounded, color: AppTheme.primary),
                  title: const Text('เรียงตามชื่อเรื่อง (ก-ฮ)'),
                  trailing: _sortBy == 'title'
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = 'title');
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
                  title: const Text('ล้างชั้นหนังสือทั้งหมด', style: TextStyle(color: AppTheme.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmClearAllBookmarks(context, bookmarkProvider);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearAllBookmarks(BuildContext context, BookmarkProvider bookmarkProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ล้างชั้นหนังสือ?'),
        content: const Text('คุณต้องการนำนิยายทั้งหมดออกจากชั้นหนังสือใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final list = List.of(bookmarkProvider.bookmarks);
              for (final b in list) {
                if (b.novel != null) {
                  await bookmarkProvider.toggleBookmark(b.novel!);
                }
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('นำนิยายออกจากชั้นหนังสือทั้งหมดแล้ว')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('ล้างทั้งหมด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final rawBookmarks = bookmarkProvider.bookmarks;

    // Apply sorting
    final bookmarks = List.of(rawBookmarks);
    if (_sortBy == 'title') {
      bookmarks.sort((a, b) => (a.novel?.title ?? '').compareTo(b.novel?.title ?? ''));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ชั้นหนังสือของฉัน'),
        actions: [
          if (bookmarks.isNotEmpty) ...[
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
              tooltip: _isGridView ? 'มุมมองรายการ (List View)' : 'มุมมองตารางปก (Grid View)',
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'ตัวเลือกการจัดเรียง',
              onPressed: () => _showShelfOptionsSheet(context),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
      body: bookmarkProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : bookmarks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bookmark_border_rounded,
                            size: 64,
                            color: AppTheme.primary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ยังไม่มีนิยายในชั้นหนังสือ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'กดไอคอนบุ๊กมาร์กที่หน้านิยายที่คุณชื่นชอบ เพื่อบันทึกมาไว้อ่านในภายหลัง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 0)),
                            );
                          },
                          icon: const Icon(Icons.explore_outlined, size: 18),
                          label: const Text('สำรวจและค้นหานิยาย'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await bookmarkProvider.fetchBookmarks();
                  },

                  child: _isGridView
                      ? _buildGridView(context, bookmarkProvider, bookmarks)
                      : _buildListView(context, bookmarkProvider, bookmarks),
                ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    BookmarkProvider bookmarkProvider,
    List<dynamic> bookmarks,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 275,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final item = bookmarks[index];
        final novel = item.novel;
        if (novel == null) return const SizedBox.shrink();

        return _buildGridCard(context, novel, bookmarkProvider);
      },
    );
  }

  Widget _buildGridCard(BuildContext context, Novel novel, BookmarkProvider bookmarkProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NovelDetailScreen(novelId: novel.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: novel.coverUrl.isNotEmpty
                        ? Image.network(
                            novel.coverUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Bottom gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Chapter count badge
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 10, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            novel.chaptersCount > 0 ? '${novel.chaptersCount} ตอน' : 'รอตอนใหม่',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Remove bookmark button on top-right
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        bookmarkProvider.toggleBookmark(novel);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ลบออกจากชั้นหนังสือแล้ว'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            novel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 13,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  novel.displayAuthorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    BookmarkProvider bookmarkProvider,
    List<dynamic> bookmarks,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = bookmarks[index];
        final novel = item.novel;
        if (novel == null) return const SizedBox.shrink();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.12),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NovelDetailScreen(novelId: novel.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 65,
                      height: 90,
                      child: novel.coverUrl.isNotEmpty
                          ? Image.network(
                              novel.coverUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 150,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'โดย ${novel.displayAuthorName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${novel.chaptersCount} ตอน',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (novel.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            novel.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_remove_outlined, color: AppTheme.error),
                    tooltip: 'ลบออกจากชั้น',
                    onPressed: () {
                      bookmarkProvider.toggleBookmark(novel);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ลบออกจากชั้นหนังสือแล้ว'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Icons.menu_book, color: Color(0xFF64748B)),
      ),
    );
  }
}
