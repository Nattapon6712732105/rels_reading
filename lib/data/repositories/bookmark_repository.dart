import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/local_novel_storage.dart';
import '../../models/bookmark.dart';
import '../../models/novel.dart';

class BookmarkRepository {
  Future<List<Bookmark>> getBookmarks() async {
    try {
      final res = await ApiClient.dio.get('/bookmarks');
      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        final backendBookmarks = list.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList();
        for (final b in backendBookmarks) {
          await LocalNovelStorage.saveBookmark(b);
        }
        return backendBookmarks;
      }
      return await LocalNovelStorage.getBookmarks();
    } on DioException catch (_) {
      // Offline fallback: return strictly what user has actually bookmarked locally
      return await LocalNovelStorage.getBookmarks();
    } catch (_) {
      return await LocalNovelStorage.getBookmarks();
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
        await LocalNovelStorage.saveBookmark(newBookmark);
        return true;
      }
      return false;
    } on DioException catch (_) {
      // Offline fallback: save locally
      await LocalNovelStorage.saveBookmark(newBookmark);
      return true;
    } catch (_) {
      await LocalNovelStorage.saveBookmark(newBookmark);
      return true;
    }
  }

  Future<bool> removeBookmark(String novelId) async {
    await LocalNovelStorage.removeBookmark(novelId);
    try {
      final res = await ApiClient.dio.delete('/bookmarks/$novelId');
      return res.data['success'] == true;
    } on DioException catch (_) {
      return true;
    } catch (_) {
      return true;
    }
  }
}

