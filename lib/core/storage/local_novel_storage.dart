import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../models/bookmark.dart';

class LocalNovelStorage {
  static const String _keyNovels = 'local_saved_novels';
  static const String _keyChaptersPrefix = 'local_chapters_';
  static const String _keyPdpaConsent = 'pdpa_copyright_consent_accepted';
  static const String _keyBookmarks = 'local_saved_bookmarks';

  // --- PDPA & Copyright Consent ---
  static Future<bool> isConsentAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPdpaConsent) ?? false;
  }

  static Future<void> setConsentAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPdpaConsent, accepted);
  }

  // --- Novel CRUD in Local Storage ---
  static Future<List<Novel>> getNovels() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyNovels);
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Novel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNovel(Novel novel) async {
    final prefs = await SharedPreferences.getInstance();
    final novels = await getNovels();
    final index = novels.indexWhere((n) => n.id == novel.id);
    if (index >= 0) {
      novels[index] = novel;
    } else {
      novels.insert(0, novel);
    }
    final encoded = jsonEncode(novels.map((n) => n.toJson()).toList());
    await prefs.setString(_keyNovels, encoded);
  }

  static Future<void> updateNovel(Novel novel) async {
    await saveNovel(novel);
  }

  static Future<void> deleteNovel(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    final novels = await getNovels();
    novels.removeWhere((n) => n.id == novelId);
    final encoded = jsonEncode(novels.map((n) => n.toJson()).toList());
    await prefs.setString(_keyNovels, encoded);

    // Also remove chapters of this novel
    await prefs.remove('$_keyChaptersPrefix$novelId');
  }

  // --- Chapter CRUD in Local Storage ---
  static Future<List<Chapter>> getChapters(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_keyChaptersPrefix$novelId');
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      final chapters = list.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
      chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      return chapters;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveChapter(Chapter chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final chapters = await getChapters(chapter.novelId);
    final index = chapters.indexWhere(
      (c) => c.id == chapter.id || c.chapterNumber == chapter.chapterNumber,
    );
    if (index >= 0) {
      chapters[index] = chapter;
    } else {
      chapters.add(chapter);
    }
    chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    final encoded = jsonEncode(chapters.map((c) => c.toJson()).toList());
    await prefs.setString('$_keyChaptersPrefix${chapter.novelId}', encoded);

    // Update novel chapter count
    final novels = await getNovels();
    final novelIdx = novels.indexWhere((n) => n.id == chapter.novelId);
    if (novelIdx >= 0) {
      novels[novelIdx] = novels[novelIdx].copyWith(chaptersCount: chapters.length);
      final encodedNovels = jsonEncode(novels.map((n) => n.toJson()).toList());
      await prefs.setString(_keyNovels, encodedNovels);
    }
  }

  // --- Bookmark CRUD in Local Storage ---
  static Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyBookmarks);
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.novelId == bookmark.novelId);
    bookmarks.insert(0, bookmark);
    final encoded = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(_keyBookmarks, encoded);
  }

  static Future<void> removeBookmark(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.novelId == novelId);
    final encoded = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(_keyBookmarks, encoded);
  }

  static Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBookmarks);
  }
}

