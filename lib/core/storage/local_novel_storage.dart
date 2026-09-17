import 'package:shared_preferences/shared_preferences.dart';

class LocalNovelStorage {
  static const String _keyPdpaConsent = 'pdpa_copyright_consent_accepted';

  // --- PDPA & Copyright Consent ---
  static Future<bool> isConsentAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPdpaConsent) ?? false;
  }

  static Future<void> setConsentAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPdpaConsent, accepted);
  }

  /// Clean legacy storage keys if any existed to immediately reclaim memory
  static Future<void> clearLegacyMemoryBloat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_saved_novels');
    await prefs.remove('local_saved_bookmarks');
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('local_chapters_')) {
        await prefs.remove(key);
      }
    }
  }
}


