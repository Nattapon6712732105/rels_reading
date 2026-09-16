import 'package:flutter_test/flutter_test.dart';
import 'package:rels_reading/config/app_config.dart';
import 'package:rels_reading/models/user.dart';
import 'package:rels_reading/models/auth_response.dart';
import 'package:rels_reading/models/novel.dart';
import 'package:rels_reading/models/chapter.dart';
import 'package:rels_reading/models/bookmark.dart';
import 'package:rels_reading/models/comment.dart';
import 'package:rels_reading/data/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rels_reading/data/repositories/novel_repository.dart';
import 'package:rels_reading/core/storage/local_novel_storage.dart';

void main() {
  group('AppConfig Tests', () {
    test('baseUrl matches Vercel deployment URL', () {
      expect(AppConfig.baseUrl, 'https://backend-gamma-ten-81.vercel.app/api');
      expect(AppConfig.appName, 'Rels Reading');
    });
  });

  group('Model Serialization Tests', () {
    test('User fromJson and toJson with LINE and Google auth', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.com',
        'username': 'tester',
        'role': 'user',
        'auth_provider': 'google',
        'google_id': 'g-123456',
        'line_user_id': 'U1234567890abcdef',
        'avatar_url': 'https://example.com/avatar.jpg',
        'created_at': '2026-09-14T10:00:00.000Z',
      };
      final user = User.fromJson(json);
      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.username, 'tester');
      expect(user.role, 'user');
      expect(user.authProvider, 'google');
      expect(user.googleId, 'g-123456');
      expect(user.lineUserId, 'U1234567890abcdef');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.isLineLinked, true);
      expect(user.isGoogleAuth, true);
      expect(user.isAdmin, false);

      final userJson = user.toJson();
      expect(userJson['email'], 'test@example.com');
      expect(userJson['auth_provider'], 'google');
      expect(userJson['line_user_id'], 'U1234567890abcdef');
      expect(userJson['google_id'], 'g-123456');

      final copied = user.copyWith(lineUserId: '', authProvider: 'local');
      expect(copied.isLineLinked, false);
      expect(copied.isGoogleAuth, false);
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

  group('LINE OA & Cover Upload Tests', () {
    test('LINE OA default info format', () {
      const botId = '@855szpwc';
      final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://line.me/R/ti/p/$botId';
      expect(qrUrl.contains('@855szpwc'), true);
      expect(qrUrl.startsWith('https://api.qrserver.com'), true);
    });

    test('Novel with Supabase Storage cover url serialized properly', () {
      const storageUrl = 'https://supabase.co/storage/v1/object/public/covers/cover-123.jpg';
      final novel = Novel(
        id: 'n-upload-1',
        title: 'นิยายทดสอบอัปโหลด',
        description: 'มีภาพปกจาก Storage',
        coverUrl: storageUrl,
        authorId: 'u-1',
        createdAt: DateTime.now(),
      );
      final json = novel.toJson();
      expect(json['cover_url'], storageUrl);
      final deserialized = Novel.fromJson(json);
      expect(deserialized.coverUrl, storageUrl);
    });
  });

  group('Novel Ownership & Security Tests', () {
    test('Non-author is prevented from deleting other users novels', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = NovelRepository();

      // Save a novel owned by author "author-alice"
      final aliceNovel = Novel(
        id: 'novel-alice-1',
        title: 'เรื่องของอลิซ',
        description: 'ลิขสิทธิ์ของอลิซเท่านั้น',
        authorId: 'author-alice',
        author: AuthorInfo(id: 'author-alice', username: 'alice'),
      );
      await LocalNovelStorage.saveNovel(aliceNovel);

      // Attempt deletion by user "hacker-bob"
      expect(
        () => repo.deleteNovel('novel-alice-1', requesterUserId: 'hacker-bob', requesterUsername: 'bob'),
        throwsA(isA<Exception>()),
      );

      // Ensure novel was NOT deleted
      final novels = await LocalNovelStorage.getNovels();
      expect(novels.any((n) => n.id == 'novel-alice-1'), true);
    });

    test('Author can successfully delete their own novel', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = NovelRepository();

      final aliceNovel = Novel(
        id: 'novel-alice-2',
        title: 'เรื่องที่สองของอลิซ',
        authorId: 'author-alice',
        author: AuthorInfo(id: 'author-alice', username: 'alice'),
      );
      await LocalNovelStorage.saveNovel(aliceNovel);

      // Attempt deletion by the legitimate author
      await repo.deleteNovel('novel-alice-2', requesterUserId: 'author-alice', requesterUsername: 'alice');

      // Verify deletion succeeded
      final novels = await LocalNovelStorage.getNovels();
      expect(novels.any((n) => n.id == 'novel-alice-2'), false);
    });
  });
}

