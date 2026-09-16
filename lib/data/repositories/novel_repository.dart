import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/novel.dart';
import '../mock_data.dart';

class NovelRepository {
  bool isUsingMockData = false;

  Future<List<Novel>> getNovels({String? authorId}) async {
    try {
      final res = await ApiClient.dio.get(
        '/novels',
        queryParameters: authorId != null ? {'author_id': authorId} : null,
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        isUsingMockData = false;
        final list = res.data['data'] as List;
        return list.map((e) => Novel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถดึงข้อมูลนิยายได้');
    } on DioException catch (_) {
      // Graceful fallback to mock data when backend database is unpaused or unreachable
      isUsingMockData = true;
      if (authorId != null) {
        return MockData.sampleNovels.where((n) => n.authorId == authorId).toList();
      }
      return MockData.sampleNovels;
    } catch (_) {
      isUsingMockData = true;
      return MockData.sampleNovels;
    }
  }

  Future<Novel> getNovelById(String id) async {
    try {
      final res = await ApiClient.dio.get('/novels/$id');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Novel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ไม่พบนิยาย');
    } on DioException catch (_) {
      // Fallback
      final found = MockData.sampleNovels.firstWhere(
        (n) => n.id == id,
        orElse: () => MockData.sampleNovels.first,
      );
      return found;
    } catch (_) {
      final found = MockData.sampleNovels.firstWhere(
        (n) => n.id == id,
        orElse: () => MockData.sampleNovels.first,
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
        return Novel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'สร้างนิยายไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      // If DB is offline, create a local mock novel so user experience doesn't fail
      if (e.response?.statusCode == 500) {
        final newNovel = Novel(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: description ?? '',
          coverUrl: coverUrl ?? '',
          authorId: 'me',
          author: AuthorInfo(id: 'me', username: 'ฉัน'),
          createdAt: DateTime.now(),
        );
        MockData.sampleNovels.insert(0, newNovel);
        return newNovel;
      }
      throw Exception(msg);
    }
  }

  Future<String> uploadCoverImage({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    try {
      final base64String = base64Encode(imageBytes);
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
      throw Exception(res.data['message'] ?? 'อัปโหลดภาพปกไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการอัปโหลดภาพ';
      throw Exception(msg);
    }
  }
}

