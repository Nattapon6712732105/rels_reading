import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bookmark_provider.dart';
import '../novel/novel_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final bookmarks = bookmarkProvider.bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ชั้นหนังสือของฉัน'),
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
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: bookmarks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = bookmarks[index];
                      final novel = item.novel;
                      if (novel == null) return const SizedBox.shrink();

                      return Card(
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
                                // Cover
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 65,
                                    height: 90,
                                    child: novel.coverUrl.isNotEmpty
                                        ? Image.network(
                                            novel.coverUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                          )
                                        : _buildPlaceholder(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Text
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
                                      Text(
                                        'โดย ${novel.displayAuthorName}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove button
                                IconButton(
                                  icon: const Icon(Icons.bookmark_remove_outlined, color: AppTheme.error),
                                  tooltip: 'ลบออกจากชั้น',
                                  onPressed: () {
                                    bookmarkProvider.toggleBookmark(novel);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
