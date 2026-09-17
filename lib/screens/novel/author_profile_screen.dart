import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/novel_provider.dart';
import '../../providers/bookmark_provider.dart';
import 'novel_detail_screen.dart';

class AuthorProfileScreen extends StatelessWidget {
  final String authorId;
  final String authorName;
  final String? avatarUrl;

  const AuthorProfileScreen({
    super.key,
    required this.authorId,
    required this.authorName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final bookmarks = context.watch<BookmarkProvider>();

    // Filter novels authored by this person
    final authorNovels = novelProvider.allNovels.where((n) {
      if (authorId.isNotEmpty && (n.authorId == authorId || n.author?.id == authorId)) {
        return true;
      }
      if (authorName.isNotEmpty &&
          n.author?.username.isNotEmpty == true &&
          n.author!.username.trim().toLowerCase() == authorName.trim().toLowerCase()) {
        return true;
      }
      return false;
    }).toList();

    int totalChapters = 0;
    for (final n in authorNovels) {
      totalChapters += n.chaptersCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์นักเขียน'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Author Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.18),
                    Theme.of(context).cardTheme.color ?? const Color(0xFF16171F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primary,
                    backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: (avatarUrl == null || avatarUrl!.isEmpty)
                        ? Text(
                            authorName.isNotEmpty ? authorName[0].toUpperCase() : 'W',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authorName.isNotEmpty ? authorName : 'นักเขียนนิรนาม',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 13, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'นักเขียน',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'นักสร้างสรรค์เรื่องราวบน Rels Reading',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${authorNovels.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ผลงานนิยาย',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$totalChapters',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ตอนที่เขียน',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Author's Novels Section Header
            Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ผลงานนิยายทั้งหมด (${authorNovels.length} เรื่อง)',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Novel Grid / List
            if (authorNovels.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                ),
                child: Center(
                  child: Text(
                    'ยังไม่มีรายการนิยายที่เผยแพร่',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: authorNovels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final novel = authorNovels[index];
                  final isSaved = bookmarks.isBookmarked(novel.id);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NovelDetailScreen(novelId: novel.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 72,
                              height: 100,
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
                                if (novel.description.isNotEmpty)
                                  Text(
                                    novel.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                      height: 1.3,
                                    ),
                                  ),
                                const SizedBox(height: 8),
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
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(
                                        isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                                        color: isSaved ? AppTheme.secondary : Colors.grey,
                                        size: 20,
                                      ),
                                      tooltip: isSaved ? 'บันทึกแล้ว' : 'เก็บเข้าชั้น',
                                      onPressed: () {
                                        bookmarks.toggleBookmark(novel);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
