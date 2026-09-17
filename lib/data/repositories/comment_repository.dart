import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/comment.dart';

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
      return [];
    } catch (_) {
      return [];
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
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    } catch (e) {
      throw Exception('ไม่สามารถส่งความคิดเห็นได้: $e');
    }
  }
}
