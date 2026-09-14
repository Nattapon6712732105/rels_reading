import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/chapter.dart';
import '../mock_data.dart';

class ChapterRepository {
  Future<List<Chapter>> getChapters(String novelId) async {
    try {
      final res = await ApiClient.dio.get(
        '/chapters',
        queryParameters: {'novel_id': novelId},
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        return list.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถดึงข้อมูลตอนได้');
    } on DioException catch (_) {
      // Fallback
      return MockData.sampleChapters[novelId] ?? [];
    } catch (_) {
      return MockData.sampleChapters[novelId] ?? [];
    }
  }

  Future<Chapter> getChapterById(String chapterId) async {
    try {
      final res = await ApiClient.dio.get('/chapters/$chapterId');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Chapter.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ไม่พบเนื้อหาตอน');
    } on DioException catch (_) {
      // Fallback search across sample chapters
      for (final chapters in MockData.sampleChapters.values) {
        for (final ch in chapters) {
          if (ch.id == chapterId) return ch;
        }
      }
      // Return default first chapter of novel 1
      return MockData.sampleChapters['mock-novel-1']!.first;
    } catch (_) {
      return MockData.sampleChapters['mock-novel-1']!.first;
    }
  }

  Future<Chapter> saveChapter({
    required String novelId,
    required int chapterNumber,
    required String title,
    String? content,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/chapters',
        data: {
          'novel_id': novelId,
          'chapter_number': chapterNumber,
          'title': title.trim(),
          'content': content?.trim() ?? '',
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Chapter.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'บันทึกตอนไม่สำเร็จ');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        final newChapter = Chapter(
          id: 'local-ch-${DateTime.now().millisecondsSinceEpoch}',
          novelId: novelId,
          chapterNumber: chapterNumber,
          title: title,
          content: content ?? '',
          createdAt: DateTime.now(),
        );
        MockData.sampleChapters.putIfAbsent(novelId, () => []).add(newChapter);
        return newChapter;
      }
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    }
  }
}
