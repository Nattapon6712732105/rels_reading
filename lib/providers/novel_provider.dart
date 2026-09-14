import 'package:flutter/foundation.dart';
import '../../data/repositories/novel_repository.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';

class NovelProvider extends ChangeNotifier {
  final NovelRepository _novelRepo = NovelRepository();
  final ChapterRepository _chapterRepo = ChapterRepository();

  List<Novel> _novels = [];
  List<Novel> _filteredNovels = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';

  // Active novel detail & chapters
  Novel? _currentNovel;
  List<Chapter> _currentChapters = [];
  bool _isLoadingChapters = false;

  List<Novel> get novels => _filteredNovels;
  List<Novel> get allNovels => _novels;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Novel? get currentNovel => _currentNovel;
  List<Chapter> get currentChapters => _currentChapters;
  bool get isLoadingChapters => _isLoadingChapters;
  bool get isUsingMockData => _novelRepo.isUsingMockData;

  final List<String> categories = [
    'ทั้งหมด',
    'กำลังภายใน',
    'โรแมนติก',
    'แฟนตาซี',
    'ไซไฟ/โลกอนาคต',
    'ชีวิตประจำวัน',
  ];

  Future<void> fetchNovels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _novels = await _novelRepo.getNovels();
      _applyFilter();
    } catch (_) {
      // Fallback already handled inside repository
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filteredNovels = _novels.where((novel) {
      final matchesSearch = novel.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          novel.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          novel.displayAuthorName.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;
      if (_selectedCategory == 'ทั้งหมด') return true;

      // Simple keyword matching for category filter
      if (_selectedCategory == 'กำลังภายใน') {
        return novel.title.contains('ราชันย์') || novel.description.contains('ปราณ') || novel.description.contains('ยุทธ์');
      } else if (_selectedCategory == 'โรแมนติก') {
        return novel.title.contains('รัก') || novel.title.contains('ดวงใจ') || novel.description.contains('ชายา');
      } else if (_selectedCategory == 'ไซไฟ/โลกอนาคต') {
        return novel.title.contains('ไซเบอร์') || novel.description.contains('แฮกเกอร์');
      } else if (_selectedCategory == 'ชีวิตประจำวัน') {
        return novel.title.contains('ร้าน') || novel.description.contains('สะดวกซื้อ');
      }
      return true;
    }).toList();
  }

  Future<void> loadNovelDetails(String novelId) async {
    _isLoadingChapters = true;
    notifyListeners();

    try {
      _currentNovel = await _novelRepo.getNovelById(novelId);
      _currentChapters = await _chapterRepo.getChapters(novelId);
      // Sort chapters by chapterNumber
      _currentChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    } finally {
      _isLoadingChapters = false;
      notifyListeners();
    }
  }

  Future<Chapter> getChapterContent(String chapterId) async {
    return await _chapterRepo.getChapterById(chapterId);
  }

  Future<Novel> createNovel({
    required String title,
    String? description,
    String? coverUrl,
  }) async {
    final newNovel = await _novelRepo.createNovel(
      title: title,
      description: description,
      coverUrl: coverUrl,
    );
    _novels.insert(0, newNovel);
    _applyFilter();
    notifyListeners();
    return newNovel;
  }

  Future<Chapter> saveChapter({
    required String novelId,
    required int chapterNumber,
    required String title,
    String? content,
  }) async {
    final chapter = await _chapterRepo.saveChapter(
      novelId: novelId,
      chapterNumber: chapterNumber,
      title: title,
      content: content,
    );
    // Refresh chapter list if current novel
    if (_currentNovel?.id == novelId) {
      _currentChapters.removeWhere((c) => c.chapterNumber == chapterNumber);
      _currentChapters.add(chapter);
      _currentChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      notifyListeners();
    }
    return chapter;
  }
}
