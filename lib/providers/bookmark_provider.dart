import 'package:flutter/foundation.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../models/bookmark.dart';
import '../../models/novel.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkRepository _repo = BookmarkRepository();

  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;

  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;

  bool isBookmarked(String novelId) {
    return _bookmarks.any((b) => b.novelId == novelId);
  }

  Future<void> fetchBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarks = await _repo.getBookmarks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleBookmark(Novel novel) async {
    final exists = isBookmarked(novel.id);
    if (exists) {
      _bookmarks.removeWhere((b) => b.novelId == novel.id);
      notifyListeners();
      return await _repo.removeBookmark(novel.id);
    } else {
      final success = await _repo.addBookmark(novel);
      if (success) {
        if (!_bookmarks.any((b) => b.novelId == novel.id)) {
          _bookmarks.insert(
            0,
            Bookmark(
              id: 'local-${DateTime.now().millisecondsSinceEpoch}',
              userId: 'me',
              novelId: novel.id,
              novel: novel,
              createdAt: DateTime.now(),
            ),
          );
          notifyListeners();
        }
      }
      return success;
    }
  }
}
