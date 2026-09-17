import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/bookmark.dart';
import '../../models/novel.dart';

class BookmarkRepository {
  final List<Bookmark> _sessionBookmarks = [];

  Future<List<Bookmark>> getBookmarks() async {
    try {
      final res = await ApiClient.dio.get('/bookmarks');
      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        return list.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _sessionBookmarks;
    } on DioException catch (_) {
      return _sessionBookmarks;
    } catch (_) {
      return _sessionBookmarks;
    }
  }

  Future<bool> addBookmark(Novel novel, {String? userId}) async {
    final newBookmark = Bookmark(
      id: 'bm-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'me',
      novelId: novel.id,
      novel: novel,
      createdAt: DateTime.now(),
    );

    try {
      final res = await ApiClient.dio.post(
        '/bookmarks',
        data: {'novel_id': novel.id},
      );

      if (res.data['success'] == true) {
        _sessionBookmarks.removeWhere((b) => b.novelId == novel.id);
        _sessionBookmarks.insert(0, newBookmark);
        return true;
      }
    } catch (_) {
      // Offline fallback: keep in memory
      _sessionBookmarks.removeWhere((b) => b.novelId == novel.id);
      _sessionBookmarks.insert(0, newBookmark);
      return true;
    }

    _sessionBookmarks.removeWhere((b) => b.novelId == novel.id);
    _sessionBookmarks.insert(0, newBookmark);
    return true;
  }

  Future<bool> removeBookmark(String novelId) async {
    _sessionBookmarks.removeWhere((b) => b.novelId == novelId);
    try {
      final res = await ApiClient.dio.delete('/bookmarks/$novelId');
      return res.data['success'] == true;
    } catch (_) {
      return true;
    }
  }
}
