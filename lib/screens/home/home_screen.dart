import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/novel_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/novel.dart';
import '../novel/novel_detail_screen.dart';
import '../novel/create_novel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: RefreshIndicator(
              onRefresh: () async {
                await novelProvider.fetchNovels();
              },
              child: CustomScrollView(
                slivers: [
                  // App Bar & Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.isLoggedIn
                                    ? 'สวัสดี, ${authProvider.user?.username}'
                                    : 'ยินดีต้อนรับสู่',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                              const Text(
                                'Rels Reading',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          // Backend connection indicator chip
                          _buildStatusChip(context, authProvider, novelProvider),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search bar & Filter Button Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (val) => novelProvider.search(val),
                              decoration: InputDecoration(
                                hintText: 'ค้นหาชื่อนิยาย, นักเขียน, เรื่องย่อ...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: novelProvider.searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 20),
                                        onPressed: () => novelProvider.search(''),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showSortFilterSheet(context, novelProvider),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withOpacity(0.15),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: AppTheme.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Horizontal List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: novelProvider.categories.length,
                    itemBuilder: (context, i) {
                      final cat = novelProvider.categories[i];
                      final isSelected = novelProvider.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => novelProvider.setCategory(cat),
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Featured Hero Card (when not searching and novels available)
              if (novelProvider.searchQuery.isEmpty && novelProvider.novels.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFeaturedCard(context, novelProvider.novels.first),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        novelProvider.selectedCategory == 'ทั้งหมด'
                            ? 'นิยายยอดนิยม'
                            : 'หมวดหมู่: ${novelProvider.selectedCategory}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${novelProvider.novels.length} เรื่อง',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Novel Grid / List
              if (novelProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (novelProvider.novels.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_stories_rounded, size: 54, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            novelProvider.searchQuery.isNotEmpty
                                ? 'ไม่พบนิยายตามคำค้นหา'
                                : 'ยังไม่มีนิยายในระบบ',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            novelProvider.searchQuery.isNotEmpty
                                ? 'ลองค้นหาด้วยคำอื่น หรือกดล้างการค้นหา'
                                : 'ร่วมเป็นนักเขียนคนแรกของ Rels Reading สร้างสรรค์ผลงานของคุณได้ทันที!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (novelProvider.searchQuery.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () => novelProvider.search(''),
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              label: const Text('ล้างการค้นหา'),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
                                );
                              },
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('เริ่มแต่งนิยายเรื่องแรก'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 175,
                      mainAxisExtent: 275,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final novel = novelProvider.novels[index];
                        return _buildNovelCard(context, novel);
                      },
                      childCount: novelProvider.novels.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    )));
  }

  Widget _buildStatusChip(BuildContext context, AuthProvider auth, NovelProvider novels) {
    final isOnline = auth.backendOnline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isOnline ? AppTheme.success : AppTheme.secondary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isOnline ? AppTheme.success : AppTheme.secondary).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.success : AppTheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Vercel API' : 'Fallback Mode',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOnline ? AppTheme.success : AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Novel novel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novel.id)),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF312E81), Color(0xFF4C1D95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background art decoration
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.auto_stories,
                size: 140,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  // Book cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 95,
                      height: 144,
                      child: novel.coverUrl.isNotEmpty
                          ? Image.network(
                              novel.coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildFallbackCover(),
                            )
                          : _buildFallbackCover(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'เรื่องแนะนำ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          novel.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'โดย ${novel.displayAuthorName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NovelDetailScreen(novelId: novel.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('อ่านเลย', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF312E81),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNovelCard(BuildContext context, Novel novel) {
    final bookmarks = context.watch<BookmarkProvider>();
    final isSaved = bookmarks.isBookmarked(novel.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novel.id)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover with bookmark button and chapter badge
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
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: novel.coverUrl.isNotEmpty
                          ? Image.network(
                              novel.coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildFallbackCover(),
                            )
                          : _buildFallbackCover(),
                    ),
                  ),
                  // Gradient shadow at bottom of cover
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 48,
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
                  // Chapter count badge (สไตล์ Web นิยาย Dek-D / ReadAWrite)
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
                  // Bookmark toggle button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => bookmarks.toggleBookmark(novel),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          size: 16,
                          color: isSaved ? AppTheme.secondary : Colors.white,
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

  Widget _buildFallbackCover() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(
          Icons.book_outlined,
          size: 40,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  void _showSortFilterSheet(BuildContext context, NovelProvider novelProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
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
                          color: Colors.grey.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'จัดเรียงและกรองนิยาย',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            novelProvider.setCategory('ทั้งหมด');
                            novelProvider.setSortBy('latest');
                            Navigator.pop(ctx);
                          },
                          child: const Text('รีเซ็ตทั้งหมด'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Sort By Options
                    const Text('จัดเรียงตาม', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('ล่าสุด'),
                          selected: novelProvider.sortBy == 'latest',
                          onSelected: (_) {
                            novelProvider.setSortBy('latest');
                            setSheetState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('จำนวนตอนมากที่สุด'),
                          selected: novelProvider.sortBy == 'chapters',
                          onSelected: (_) {
                            novelProvider.setSortBy('chapters');
                            setSheetState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('ชื่อเรื่อง ก-ฮ'),
                          selected: novelProvider.sortBy == 'title',
                          onSelected: (_) {
                            novelProvider.setSortBy('title');
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Categories
                    const Text('หมวดหมู่', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: novelProvider.categories.map((cat) {
                        final isSelected = novelProvider.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            novelProvider.setCategory(cat);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('นำไปใช้'),
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
}
