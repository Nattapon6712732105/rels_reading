import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/novel_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/novel.dart';
import '../novel/novel_detail_screen.dart';
import '../novel/create_novel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController();
  Timer? _heroTimer;
  int _heroPage = 0;

  @override
  void initState() {
    super.initState();
    _startHeroTimer();
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final novelProvider = context.read<NovelProvider>();
      final heroNovels = _getHeroNovels(novelProvider.allNovels);
      if (heroNovels.isEmpty) return;
      final next = (_heroPage + 1) % heroNovels.length;
      _heroController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  List<Novel> _getHeroNovels(List<Novel> all) {
    if (all.isEmpty) return [];
    return all.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final authProvider = context.watch<AuthProvider>();
    final heroNovels = _getHeroNovels(novelProvider.allNovels);
    final isSearching = novelProvider.searchQuery.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await novelProvider.fetchNovels();
        },
        child: CustomScrollView(
          slivers: [
            // ── Collapsible App Bar ──────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              titleSpacing: 20,
              title: Row(
                children: [
                  // Logo
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Rels Reading',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'ค้นหา',
                  onPressed: () => _showSearchSheet(context, novelProvider),
                ),
                if (authProvider.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary.withOpacity(0.18),
                      child: Text(
                        (authProvider.user?.username ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),

            // ── Search Active Banner ─────────────────────────────────────
            if (isSearching)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ผลลัพธ์สำหรับ: "${novelProvider.searchQuery}"',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => novelProvider.search(''),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Hero Carousel ────────────────────────────────────────────
            if (!isSearching && heroNovels.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 230,
                      child: PageView.builder(
                        controller: _heroController,
                        itemCount: heroNovels.length,
                        onPageChanged: (i) => setState(() => _heroPage = i),
                        itemBuilder: (context, index) {
                          return _buildHeroSlide(context, heroNovels[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(heroNovels.length, (i) {
                        final isActive = i == _heroPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.primary : Colors.grey.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

            // ── Category Pill Tabs ───────────────────────────────────────
            if (!isSearching)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: novelProvider.categories.length,
                    itemBuilder: (context, i) {
                      final cat = novelProvider.categories[i];
                      final isSelected = novelProvider.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => novelProvider.setCategory(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Recently Updated Horizontal Section ──────────────────────
            if (!isSearching && novelProvider.allNovels.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'อัปเดตล่าสุด', Icons.update_rounded, novelProvider),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 195,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: novelProvider.allNovels.length.clamp(0, 10),
                        itemBuilder: (context, index) {
                          final novel = novelProvider.allNovels[index];
                          return _buildHorizontalCard(context, novel);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            // ── All Novels Section Header ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      novelProvider.selectedCategory == 'ทั้งหมด'
                          ? 'นิยายทั้งหมด'
                          : novelProvider.selectedCategory,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // Sort button
                    GestureDetector(
                      onTap: () => _showSortFilterSheet(context, novelProvider),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: Colors.grey.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            'จัดเรียง',
                            style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Novel 2-Column Grid ──────────────────────────────────────
            if (novelProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else if (novelProvider.novels.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context, novelProvider),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.58, // Portrait 2:3-ish like Webtoons
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNovelCard(context, novelProvider.novels[index]),
                    childCount: novelProvider.novels.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      // FAB for creating novel
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('แต่งนิยาย', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  // ── Hero Slide ─────────────────────────────────────────────────────────────
  Widget _buildHeroSlide(BuildContext context, Novel novel) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novel.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background cover
              novel.coverUrl.isNotEmpty
                  ? Image.network(novel.coverUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildGradientFallback())
                  : _buildGradientFallback(),
              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.transparent, Color(0xCC000000)],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              // Content overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'เรื่องแนะนำ',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        novel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_rounded, size: 12, color: Colors.white.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(
                            novel.displayAuthorName,
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'อ่านเลย',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Horizontal Card (recently updated) ────────────────────────────────────
  Widget _buildHorizontalCard(BuildContext context, Novel novel) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novel.id)),
      ),
      child: Container(
        width: 115,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    novel.coverUrl.isNotEmpty
                        ? Image.network(novel.coverUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildSmallFallback())
                        : _buildSmallFallback(),
                    if (novel.chaptersCount > 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${novel.chaptersCount} ตอน',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              novel.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.25),
            ),
            const SizedBox(height: 2),
            Text(
              novel.displayAuthorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2-Column Novel Card ────────────────────────────────────────────────────
  Widget _buildNovelCard(BuildContext context, Novel novel) {
    final bookmarks = context.watch<BookmarkProvider>();
    final isSaved = bookmarks.isBookmarked(novel.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novel.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: novel.coverUrl.isNotEmpty
                      ? Image.network(
                          novel.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackCover(),
                        )
                      : _buildFallbackCover(),
                ),
                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 55,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                  ),
                ),
                // Chapter badge bottom-left
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 9, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          novel.chaptersCount > 0 ? '${novel.chaptersCount} ตอน' : 'รอตอนใหม่',
                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark button top-right
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => bookmarks.toggleBookmark(novel),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        size: 15,
                        color: isSaved ? AppTheme.secondary : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            novel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.25),
          ),
          const SizedBox(height: 3),
          Text(
            novel.displayAuthorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, NovelProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, NovelProvider novelProvider) {
    return Center(
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
              novelProvider.searchQuery.isNotEmpty ? 'ไม่พบนิยายที่ค้นหา' : 'ยังไม่มีนิยายในระบบ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              novelProvider.searchQuery.isNotEmpty
                  ? 'ลองค้นหาด้วยคำอื่น'
                  : 'ร่วมเป็นนักเขียนคนแรกของ Rels Reading!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateNovelScreen()),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('เริ่มแต่งนิยาย'),
              ),
          ],
        ),
      ),
    );
  }

  // ── Fallback Covers ────────────────────────────────────────────────────────
  Widget _buildGradientFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Icon(Icons.auto_stories, size: 60, color: Colors.white24)),
    );
  }

  Widget _buildSmallFallback() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(child: Icon(Icons.book_outlined, size: 28, color: Color(0xFF64748B))),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(child: Icon(Icons.book_outlined, size: 36, color: Color(0xFF475569))),
    );
  }

  // ── Search Bottom Sheet ────────────────────────────────────────────────────
  void _showSearchSheet(BuildContext context, NovelProvider novelProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              TextField(
                autofocus: true,
                onChanged: (val) => novelProvider.search(val),
                decoration: InputDecoration(
                  hintText: 'ค้นหาชื่อนิยาย, นักเขียน, เรื่องย่อ...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                  suffixIcon: novelProvider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () => novelProvider.search(''),
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ค้นหา'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ── Sort / Filter Bottom Sheet ─────────────────────────────────────────────
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
                        const Text('จัดเรียงและกรอง', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            novelProvider.setCategory('ทั้งหมด');
                            novelProvider.setSortBy('latest');
                            Navigator.pop(ctx);
                          },
                          child: const Text('รีเซ็ต'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                          label: const Text('จำนวนตอนมากสุด'),
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
                    const SizedBox(height: 16),
                    const Text('หมวดหมู่', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: novelProvider.categories.map((cat) {
                        return ChoiceChip(
                          label: Text(cat),
                          selected: novelProvider.selectedCategory == cat,
                          onSelected: (_) {
                            novelProvider.setCategory(cat);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
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



