import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../models/comment.dart';
import '../../providers/reader_settings_provider.dart';
import '../../providers/novel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/repositories/comment_repository.dart';

class ReaderScreen extends StatefulWidget {
  final Novel novel;
  final Chapter chapter;
  final List<Chapter> allChapters;

  const ReaderScreen({
    super.key,
    required this.novel,
    required this.chapter,
    required this.allChapters,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Chapter _currentChapter;
  bool _isLoadingContent = false;
  String _chapterContent = '';
  final ScrollController _scrollController = ScrollController();
  final CommentRepository _commentRepo = CommentRepository();

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoadingContent = true;
    });

    try {
      final novelProvider = context.read<NovelProvider>();
      final fullChapter = await novelProvider.getChapterContent(_currentChapter.id);
      if (mounted) {
        setState(() {
          _chapterContent = fullChapter.content.isNotEmpty
              ? fullChapter.content
              : _currentChapter.content;
          _isLoadingContent = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _chapterContent = _currentChapter.content;
          _isLoadingContent = false;
        });
      }
    }
  }

  void _goToChapter(Chapter target) {
    setState(() {
      _currentChapter = target;
      _chapterContent = '';
    });
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _loadContent();
  }

  Chapter? get _previousChapter {
    final idx = widget.allChapters.indexWhere((c) => c.id == _currentChapter.id);
    if (idx > 0) return widget.allChapters[idx - 1];
    return null;
  }

  Chapter? get _nextChapter {
    final idx = widget.allChapters.indexWhere((c) => c.id == _currentChapter.id);
    if (idx >= 0 && idx < widget.allChapters.length - 1) {
      return widget.allChapters[idx + 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ReaderSettingsProvider>();

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        foregroundColor: settings.textColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.novel.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: settings.textColor.withOpacity(0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              _currentChapter.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: settings.textColor,
              ),
            ),
          ],
        ),
        actions: [
          // Table of Contents Button (Chapter Selector Bottom Sheet)
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded),
            tooltip: 'สารบัญตอน',
            onPressed: _showChapterSelectorSheet,
          ),
          // Comments Button
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            tooltip: 'ความคิดเห็น',
            onPressed: _showCommentsSheet,
          ),
          // Reader Settings Button
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'ปรับแต่งการอ่าน',
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: _isLoadingContent
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chapter Title Header
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _currentChapter.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: settings.fontSize + 4,
                            fontWeight: FontWeight.bold,
                            color: settings.textColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 32),

                    // Chapter Text
                    SelectableText(
                      _chapterContent.isNotEmpty
                          ? _chapterContent.trim()
                          : 'ไม่มีเนื้อหาในตอนนี้',
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        color: settings.textColor,
                        height: settings.lineHeight,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 48),
                    const Divider(height: 32),

                    // Navigation to Next/Previous Chapter
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previousChapter != null
                                ? () => _goToChapter(_previousChapter!)
                                : null,
                            icon: const Icon(Icons.arrow_back_rounded, size: 16),
                            label: const Text('ตอนก่อนหน้า'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: settings.textColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: settings.textColor.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nextChapter != null
                                ? () => _goToChapter(_nextChapter!)
                                : null,
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: const Text('ตอนถัดไป'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Comments Bar
                    Center(
                      child: TextButton.icon(
                        onPressed: _showCommentsSheet,
                        icon: const Icon(Icons.comment_outlined, size: 18),
                        label: const Text('ดูความคิดเห็นทั้งหมด / แสดงความคิดเห็น'),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }

  void _showSettingsSheet() {
    final settings = context.read<ReaderSettingsProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: settings.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: settings.textColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'การตั้งค่าการอ่าน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: settings.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Theme Selector
                  Text(
                    'โทนสีพื้นหลัง',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: settings.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeChoice(
                        title: 'สว่าง',
                        mode: ReaderThemeMode.light,
                        bg: AppTheme.readerLightBg,
                        border: Colors.grey.shade400,
                        textColor: Colors.black,
                        settings: settings,
                        onTap: () {
                          settings.setThemeMode(ReaderThemeMode.light);
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildThemeChoice(
                        title: 'ซีเปีย',
                        mode: ReaderThemeMode.sepia,
                        bg: AppTheme.readerSepiaBg,
                        border: const Color(0xFFD4C3A3),
                        textColor: const Color(0xFF4A3E30),
                        settings: settings,
                        onTap: () {
                          settings.setThemeMode(ReaderThemeMode.sepia);
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildThemeChoice(
                        title: 'กลางคืน',
                        mode: ReaderThemeMode.dark,
                        bg: AppTheme.readerDarkBg,
                        border: const Color(0xFF2D3748),
                        textColor: Colors.white,
                        settings: settings,
                        onTap: () {
                          settings.setThemeMode(ReaderThemeMode.dark);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ขนาดตัวอักษร',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: settings.textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${settings.fontSize.toInt()} px',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: settings.textColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.fontSize,
                    min: 14.0,
                    max: 28.0,
                    divisions: 7,
                    activeColor: AppTheme.primary,
                    onChanged: (val) {
                      settings.setFontSize(val);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeChoice({
    required String title,
    required ReaderThemeMode mode,
    required Color bg,
    required Color border,
    required Color textColor,
    required ReaderSettingsProvider settings,
    required VoidCallback onTap,
  }) {
    final isSelected = settings.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : border,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet() {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<List<Comment>>(
              future: _commentRepo.getComments(_currentChapter.id),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                final auth = context.read<AuthProvider>();

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          children: [
                            const Icon(Icons.forum_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ความคิดเห็น (${comments.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Comment list
                      Expanded(
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator())
                            : comments.isEmpty
                                ? Center(
                                    child: Text(
                                      'ยังไม่มีความคิดเห็นในตอนนี้ มาร่วมคุยเป็นคนแรก!',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: comments.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final c = comments[index];
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardTheme.color,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                                                  child: Text(
                                                    c.user?.username.isNotEmpty == true
                                                        ? c.user!.username[0].toUpperCase()
                                                        : 'U',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  c.user?.username ?? 'ผู้อ่าน',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              c.content,
                                              style: const TextStyle(fontSize: 14, height: 1.4),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),

                      // Input Bar
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: const InputDecoration(
                                  hintText: 'เขียนความคิดเห็น...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.send_rounded, size: 20),
                              onPressed: () async {
                                final text = commentController.text.trim();
                                if (text.isEmpty) return;

                                await _commentRepo.createComment(
                                  chapterId: _currentChapter.id,
                                  content: text,
                                  currentUsername: auth.user?.username,
                                );
                                commentController.clear();
                                if (ctx.mounted && mounted) {
                                  Navigator.of(ctx).pop();
                                  _showCommentsSheet();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showChapterSelectorSheet() {
    final settings = context.read<ReaderSettingsProvider>();
    final allChapters = widget.allChapters;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? allChapters
                : allChapters.where((c) {
                    return c.title.toLowerCase().contains(query) ||
                        c.chapterNumber.toString().contains(query);
                  }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (sheetCtx, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: settings.backgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: settings.textColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'สารบัญตอน (${allChapters.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: settings.textColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: settings.textColor),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) => setSheetState(() {}),
                          style: TextStyle(color: settings.textColor),
                          decoration: InputDecoration(
                            hintText: 'ค้นหาเลขตอน หรือชื่อตอน...',
                            prefixIcon: Icon(Icons.search_rounded, color: settings.textColor.withOpacity(0.6)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: settings.textColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'ไม่พบตอนที่ค้นหา',
                                  style: TextStyle(color: settings.textColor.withOpacity(0.7)),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final ch = filtered[index];
                                  final isCurrent = ch.id == _currentChapter.id;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppTheme.primary.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCurrent
                                            ? AppTheme.primary
                                            : settings.textColor.withOpacity(0.1),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: isCurrent
                                            ? AppTheme.primary
                                            : settings.textColor.withOpacity(0.1),
                                        child: Text(
                                          '${ch.chapterNumber}',
                                          style: TextStyle(
                                            color: isCurrent ? Colors.white : settings.textColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        ch.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isCurrent ? AppTheme.primary : settings.textColor,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: isCurrent
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'กำลังอ่าน',
                                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          : Icon(Icons.arrow_forward_ios_rounded, size: 12, color: settings.textColor.withOpacity(0.4)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _goToChapter(ch);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
