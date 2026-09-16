import '../../core/api/api_client.dart';
import '../../core/storage/local_novel_storage.dart';
import '../../models/chapter.dart';
import '../mock_data.dart';

class ChapterRepository {
  Future<List<Chapter>> getChapters(String novelId) async {
    final localChapters = await LocalNovelStorage.getChapters(novelId);

    try {
      final res = await ApiClient.dio.get(
        '/chapters',
        queryParameters: {'novel_id': novelId},
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        final remoteChapters = list.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();

        // Merge with local chapters
        final Map<String, Chapter> map = {};
        for (final c in localChapters) {
          map['${c.chapterNumber}'] = c;
        }
        for (final c in remoteChapters) {
          map['${c.chapterNumber}'] = c;
        }
        final merged = map.values.toList();
        merged.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
        return merged;
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถดึงข้อมูลตอนได้');
    } catch (_) {
      if (localChapters.isNotEmpty) {
        return localChapters;
      }
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
    } catch (_) {
      // Search in sample chapters or throw
      for (final chapters in MockData.sampleChapters.values) {
        for (final ch in chapters) {
          if (ch.id == chapterId) return ch;
        }
      }
      if (MockData.sampleChapters['mock-novel-1']?.isNotEmpty == true) {
        return MockData.sampleChapters['mock-novel-1']!.first;
      }
      throw Exception('ไม่พบเนื้อหาตอน');
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
        final saved = Chapter.fromJson(res.data['data'] as Map<String, dynamic>);
        await LocalNovelStorage.saveChapter(saved);
        return saved;
      }
      throw Exception(res.data['message'] ?? 'บันทึกตอนไม่สำเร็จ');
    } catch (_) {
      // Offline / Error fallback: save persistently in local storage
      final newChapter = Chapter(
        id: 'local-ch-${DateTime.now().millisecondsSinceEpoch}',
        novelId: novelId,
        chapterNumber: chapterNumber,
        title: title.trim(),
        content: content?.trim() ?? '',
        createdAt: DateTime.now(),
      );
      await LocalNovelStorage.saveChapter(newChapter);
      MockData.sampleChapters.putIfAbsent(novelId, () => []).add(newChapter);
      return newChapter;
    }
  }
}
