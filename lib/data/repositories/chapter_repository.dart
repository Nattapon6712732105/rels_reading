import '../../core/api/api_client.dart';
import '../../models/chapter.dart';

class ChapterRepository {
  Future<List<Chapter>> getChapters(String novelId) async {
    try {
      final res = await ApiClient.dio.get(
        '/chapters',
        queryParameters: {'novel_id': novelId},
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        final chapters = list.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
        chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
        return chapters;
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถดึงข้อมูลตอนได้');
    } catch (e) {
      throw Exception('ไม่สามารถดึงรายการตอนได้: $e');
    }
  }

  Future<Chapter> getChapterById(String chapterId) async {
    try {
      final res = await ApiClient.dio.get('/chapters/$chapterId');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Chapter.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ไม่พบเนื้อหาตอน');
    } catch (e) {
      throw Exception('ไม่สามารถดึงเนื้อหาตอนนี้ได้: $e');
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
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการบันทึกตอน: $e');
    }
  }
}
