import 'package:flutter_test/flutter_test.dart';
import 'package:rels_reading/config/app_config.dart';
import 'package:rels_reading/models/user.dart';
import 'package:rels_reading/models/auth_response.dart';
import 'package:rels_reading/models/novel.dart';
import 'package:rels_reading/models/chapter.dart';
import 'package:rels_reading/models/bookmark.dart';
import 'package:rels_reading/models/comment.dart';
import 'package:rels_reading/data/mock_data.dart';

void main() {
  group('AppConfig Tests', () {
    test('baseUrl matches Vercel deployment URL', () {
      expect(AppConfig.baseUrl, 'https://backend-gamma-ten-81.vercel.app/api');
      expect(AppConfig.appName, 'Rels Reading');
    });
  });

  group('Model Serialization Tests', () {
    test('User fromJson and toJson', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.com',
        'username': 'tester',
        'role': 'user',
        'created_at': '2026-09-14T10:00:00.000Z',
      };
      final user = User.fromJson(json);
      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.username, 'tester');
      expect(user.role, 'user');
      expect(user.isAdmin, false);
      expect(user.toJson()['email'], 'test@example.com');
    });

    test('AuthResponse fromJson', () {
      final json = {
        'user': {
          'id': 'u-1',
          'email': 'u@e.com',
          'username': 'u1',
          'role': 'admin',
        },
        'tokens': {
          'accessToken': 'token_abc',
          'refreshToken': 'refresh_xyz',
        },
      };
      final authRes = AuthResponse.fromJson(json);
      expect(authRes.user.username, 'u1');
      expect(authRes.user.isAdmin, true);
      expect(authRes.tokens.accessToken, 'token_abc');
      expect(authRes.tokens.refreshToken, 'refresh_xyz');
    });

    test('Novel fromJson and toJson', () {
      final json = {
        'id': 'novel-1',
        'title': 'สุดยอดคัมภีร์ยุทธ์',
        'description': 'เรื่องย่อการผจญภัย',
        'cover_url': 'https://example.com/cover.jpg',
        'author_id': 'author-1',
        'author': {
          'id': 'author-1',
          'username': 'จอมยุทธ์พเนจร',
        },
        'chapters_count': 50,
      };
      final novel = Novel.fromJson(json);
      expect(novel.id, 'novel-1');
      expect(novel.title, 'สุดยอดคัมภีร์ยุทธ์');
      expect(novel.displayAuthorName, 'จอมยุทธ์พเนจร');
      expect(novel.chaptersCount, 50);
      expect(novel.toJson()['title'], 'สุดยอดคัมภีร์ยุทธ์');
    });

    test('Chapter fromJson and toJson', () {
      final json = {
        'id': 'ch-1',
        'novel_id': 'novel-1',
        'chapter_number': 1,
        'title': 'บทที่ 1 ปฐมบท',
        'content': 'เนื้อหาของตอนที่ 1',
      };
      final ch = Chapter.fromJson(json);
      expect(ch.id, 'ch-1');
      expect(ch.novelId, 'novel-1');
      expect(ch.chapterNumber, 1);
      expect(ch.title, 'บทที่ 1 ปฐมบท');
      expect(ch.content, 'เนื้อหาของตอนที่ 1');
      expect(ch.toJson()['chapter_number'], 1);
    });

    test('Bookmark fromJson', () {
      final json = {
        'id': 'bm-1',
        'user_id': 'u-1',
        'novel_id': 'novel-1',
        'novel': {
          'id': 'novel-1',
          'title': 'นิยายทดสอบ',
          'author_id': 'a-1',
        },
      };
      final bm = Bookmark.fromJson(json);
      expect(bm.id, 'bm-1');
      expect(bm.novel?.title, 'นิยายทดสอบ');
    });

    test('Comment fromJson', () {
      final json = {
        'id': 'c-1',
        'chapter_id': 'ch-1',
        'user_id': 'u-1',
        'content': 'ตอนนี้น่าติดตามมากครับ!',
        'user': {
          'id': 'u-1',
          'username': 'นักอ่านหมายเลขหนึ่ง',
        },
      };
      final comment = Comment.fromJson(json);
      expect(comment.content, 'ตอนนี้น่าติดตามมากครับ!');
      expect(comment.user?.username, 'นักอ่านหมายเลขหนึ่ง');
    });
  });

  group('MockData Fallback Verification', () {
    test('sampleNovels is populated', () {
      expect(MockData.sampleNovels.isNotEmpty, true);
      expect(MockData.sampleNovels.length >= 4, true);
    });

    test('sampleChapters is mapped correctly', () {
      expect(MockData.sampleChapters['mock-novel-1']?.isNotEmpty, true);
    });
  });
}
