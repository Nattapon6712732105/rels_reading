import 'dart:convert';
import 'dart:typed_data';
import '../../core/api/api_client.dart';
import '../../core/storage/local_novel_storage.dart';
import '../../models/novel.dart';

class NovelRepository {
  bool isUsingMockData = false;

  Future<List<Novel>> getNovels({String? authorId}) async {
    final localNovels = await LocalNovelStorage.getNovels();

    try {
      final res = await ApiClient.dio.get(
        '/novels',
        queryParameters: authorId != null ? {'author_id': authorId} : null,
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        isUsingMockData = false;
        final list = res.data['data'] as List;
        final remoteNovels = list.map((e) => Novel.fromJson(e as Map<String, dynamic>)).toList();

        // Merge remote novels with locally created novels (avoiding duplicate IDs)
        final Map<String, Novel> novelMap = {};
        for (final n in localNovels) {
          novelMap[n.id] = n;
        }
        for (final n in remoteNovels) {
          novelMap[n.id] = n;
        }

        final combined = novelMap.values.toList();
        if (authorId != null) {
          return combined.where((n) => n.authorId == authorId).toList();
        }
        return combined;
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถดึงข้อมูลนิยายได้');
    } catch (_) {
      // Backend offline or error: use persistently saved local novels (Mock test novels removed)
      isUsingMockData = false;
      if (authorId != null) {
        return localNovels.where((n) => n.authorId == authorId).toList();
      }
      return localNovels;
    }
  }

  Future<Novel> getNovelById(String id) async {
    try {
      final res = await ApiClient.dio.get('/novels/$id');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        final novel = Novel.fromJson(res.data['data'] as Map<String, dynamic>);
        await LocalNovelStorage.saveNovel(novel);
        return novel;
      }
      throw Exception(res.data['message'] ?? 'ไม่พบนิยาย');
    } catch (_) {
      final localNovels = await LocalNovelStorage.getNovels();
      final found = localNovels.firstWhere(
        (n) => n.id == id,
        orElse: () => throw Exception('ไม่พบข้อมูลนิยาย'),
      );
      return found;
    }
  }

  Future<Novel> createNovel({
    required String title,
    String? description,
    String? coverUrl,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/novels',
        data: {
          'title': title.trim(),
          if (description != null && description.isNotEmpty) 'description': description.trim(),
          if (coverUrl != null && coverUrl.isNotEmpty) 'cover_url': coverUrl.trim(),
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        final created = Novel.fromJson(res.data['data'] as Map<String, dynamic>);
        await LocalNovelStorage.saveNovel(created);
        return created;
      }
      throw Exception(res.data['message'] ?? 'สร้างนิยายไม่สำเร็จ');
    } catch (_) {
      // If backend API fails, save persistently in local storage so author's work is NEVER lost
      final newNovel = Novel(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        title: title.trim(),
        description: description?.trim() ?? '',
        coverUrl: coverUrl?.trim() ?? '',
        authorId: 'me',
        author: AuthorInfo(id: 'me', username: 'ฉัน'),
        createdAt: DateTime.now(),
        chaptersCount: 0,
      );
      await LocalNovelStorage.saveNovel(newNovel);
      return newNovel;
    }
  }

  Future<Novel> updateNovel({
    required String id,
    required String title,
    String? description,
    String? coverUrl,
  }) async {
    Novel? updatedNovel;
    try {
      final res = await ApiClient.dio.put(
        '/novels/$id',
        data: {
          'title': title.trim(),
          if (description != null) 'description': description.trim(),
          if (coverUrl != null) 'cover_url': coverUrl.trim(),
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        updatedNovel = Novel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Continue to local update
    }

    if (updatedNovel == null) {
      final current = await getNovelById(id);
      updatedNovel = current.copyWith(
        title: title.trim(),
        description: description?.trim() ?? current.description,
        coverUrl: coverUrl?.trim() ?? current.coverUrl,
      );
    }

    await LocalNovelStorage.updateNovel(updatedNovel);
    return updatedNovel;
  }

  Future<void> deleteNovel(String id) async {
    try {
      await ApiClient.dio.delete('/novels/$id');
    } catch (_) {
      // Local fallback
    }
    await LocalNovelStorage.deleteNovel(id);
  }

  Future<String> uploadCoverImage({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final base64String = base64Encode(imageBytes);

    try {
      final res = await ApiClient.dio.post(
        '/upload/cover',
        data: {
          'image': base64String,
          'filename': filename,
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        final url = res.data['data']['url'] as String?;
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
    } catch (_) {
      // Fallback: If upload endpoint is not available (404/500), use data URI so image displays flawlessly
    }

    // Return Data URI so the image is rendered anywhere without crashing
    return 'data:image/jpeg;base64,$base64String';
  }
}
