import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/bookmark.dart';
import '../../models/novel.dart';
import '../mock_data.dart';

class BookmarkRepository {
  // Local cached fallback bookmarks
  final List<Bookmark> _localBookmarks = [];

  Future<List<Bookmark>> getBookmarks() async {
    try {
      final res = await ApiClient.dio.get('/bookmarks');
      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        return list.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _localBookmarks;
    } on DioException catch (_) {
      // Fallback
      if (_localBookmarks.isEmpty) {
        _localBookmarks.add(
          Bookmark(
            id: 'local-bm-1',
            userId: 'me',
            novelId: MockData.sampleNovels.first.id,
            novel: MockData.sampleNovels.first,
            createdAt: DateTime.now(),
          ),
        );
      }
      return _localBookmarks;
    } catch (_) {
      return _localBookmarks;
    }
  }

  Future<bool> addBookmark(Novel novel) async {
    try {
      final res = await ApiClient.dio.post(
        '/bookmarks',
        data: {'novel_id': novel.id},
      );

      if (res.data['success'] == true) {
        _localBookmarks.removeWhere((b) => b.novelId == novel.id);
        _localBookmarks.insert(
          0,
          Bookmark(
            id: 'bm-${DateTime.now().millisecondsSinceEpoch}',
            userId: 'me',
            novelId: novel.id,
            novel: novel,
            createdAt: DateTime.now(),
          ),
        );
        return true;
      }
      return false;
    } on DioException catch (_) {
      // Offline fallback
      _localBookmarks.removeWhere((b) => b.novelId == novel.id);
      _localBookmarks.insert(
        0,
        Bookmark(
          id: 'local-bm-${DateTime.now().millisecondsSinceEpoch}',
          userId: 'me',
          novelId: novel.id,
          novel: novel,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeBookmark(String novelId) async {
    try {
      final res = await ApiClient.dio.delete('/bookmarks/$novelId');
      _localBookmarks.removeWhere((b) => b.novelId == novelId);
      return res.data['success'] == true;
    } on DioException catch (_) {
      _localBookmarks.removeWhere((b) => b.novelId == novelId);
      return true;
    } catch (_) {
      _localBookmarks.removeWhere((b) => b.novelId == novelId);
      return true;
    }
  }
}
