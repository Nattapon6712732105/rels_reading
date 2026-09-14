import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/comment.dart';
import '../mock_data.dart';

class CommentRepository {
  Future<List<Comment>> getComments(String chapterId) async {
    try {
      final res = await ApiClient.dio.get(
        '/comments',
        queryParameters: {'chapter_id': chapterId},
      );

      if (res.data['success'] == true && res.data['data'] is List) {
        final list = res.data['data'] as List;
        return list.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
      }
      return MockData.sampleComments[chapterId] ?? [];
    } on DioException catch (_) {
      return MockData.sampleComments[chapterId] ?? [];
    } catch (_) {
      return MockData.sampleComments[chapterId] ?? [];
    }
  }

  Future<Comment> createComment({
    required String chapterId,
    required String content,
    String? currentUsername,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/comments',
        data: {
          'chapter_id': chapterId,
          'content': content.trim(),
        },
      );

      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return Comment.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ส่งความคิดเห็นไม่สำเร็จ');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        final newComment = Comment(
          id: 'local-com-${DateTime.now().millisecondsSinceEpoch}',
          chapterId: chapterId,
          userId: 'me',
          content: content,
          user: CommentUser(id: 'me', username: currentUsername ?? 'ฉัน'),
          createdAt: DateTime.now(),
        );
        MockData.sampleComments.putIfAbsent(chapterId, () => []).insert(0, newComment);
        return newComment;
      }
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    }
  }
}
