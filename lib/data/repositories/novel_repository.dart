import 'dart:convert';
import 'dart:typed_data';
import '../../core/api/api_client.dart';
import '../../models/novel.dart';

class NovelRepository {
  bool isUsingMockData = false;

  Future<List<Novel>> getNovels({String? authorId}) async {
    try {
      final res = await ApiClient.dio.get(
        '/novels',
        queryParameters: authorId != null ? {'author_id': authorId} : null,
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        return list.map((e) => Novel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถดึงข้อมูลนิยายได้');
    } catch (e) {
      // Re-throw with clear message
      throw Exception('ไม่สามารถเชื่อมต่อดึงข้อมูลนิยายได้: $e');
    }
  }

  Future<Novel> getNovelById(String id) async {
    try {
      final res = await ApiClient.dio.get('/novels/$id');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Novel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ไม่พบนิยาย');
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลนิยายเรื่องนี้ได้: $e');
    }
  }

  Future<Novel> createNovel({
    required String title,
    String? description,
    String? coverUrl,
    String? authorId,
    String? authorName,
    List<String>? tags,
  }) async {
    final effectiveAuthorId = (authorId != null && authorId.isNotEmpty) ? authorId : 'anonymous';
    final effectiveAuthorName = (authorName != null && authorName.isNotEmpty) ? authorName : 'นักเขียน';
    final effectiveTags = tags ?? [];

    try {
      final res = await ApiClient.dio.post(
        '/novels',
        data: {
          'title': title.trim(),
          if (description != null && description.isNotEmpty) 'description': description.trim(),
          if (coverUrl != null && coverUrl.isNotEmpty) 'cover_url': coverUrl.trim(),
          'author_id': effectiveAuthorId,
          'author_username': effectiveAuthorName,
          'tags': effectiveTags,
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        final created = Novel.fromJson(res.data['data'] as Map<String, dynamic>);
        return (created.authorId.isEmpty || created.author == null)
            ? created.copyWith(
                authorId: effectiveAuthorId,
                author: AuthorInfo(id: effectiveAuthorId, username: effectiveAuthorName),
                tags: created.tags.isNotEmpty ? created.tags : effectiveTags,
              )
            : created;
      }
      throw Exception(res.data['message'] ?? 'สร้างนิยายไม่สำเร็จ');
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการสร้างนิยาย: $e');
    }
  }

  Future<Novel> updateNovel({
    required String id,
    required String title,
    String? description,
    String? coverUrl,
    String? requesterUserId,
    String? requesterUsername,
    List<String>? tags,
  }) async {
    try {
      final res = await ApiClient.dio.put(
        '/novels/$id',
        data: {
          'title': title.trim(),
          if (description != null) 'description': description.trim(),
          if (coverUrl != null) 'cover_url': coverUrl.trim(),
          if (tags != null && tags.isNotEmpty) 'tags': tags,
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Novel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'แก้ไขนิยายไม่สำเร็จ');
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการอัปเดตนิยาย: $e');
    }
  }

  Future<void> deleteNovel(
    String id, {
    String? requesterUserId,
    String? requesterUsername,
  }) async {
    try {
      final res = await ApiClient.dio.delete('/novels/$id');
      if (res.data['success'] != true) {
        throw Exception(res.data['message'] ?? 'ลบนิยายไม่สำเร็จ');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการลบนิยาย: $e');
    }
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
      // Fallback
    }

    return 'data:image/jpeg;base64,$base64String';
  }
}
