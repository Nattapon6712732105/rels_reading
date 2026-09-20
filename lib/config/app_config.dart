import 'package:flutter/foundation.dart';

class AppConfig {
  /// Local backend URL on port 5000
  static const String localBaseUrl = 'http://localhost:5000/api';

  /// Remote backend URL on Vercel
  static const String remoteBaseUrl = 'https://backend-gamma-ten-81.vercel.app/api';

  /// Active Base URL
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return localBaseUrl;
      }
      return remoteBaseUrl;
    }
    // On Mobile / APK: Always connect to remote Vercel backend
    return remoteBaseUrl;
  }

  /// Google OAuth Client ID for Web / Sign In
  static const String googleClientId =
      '267211717334-bg6su72vc71oaaenjspuhtoq5gmfdrf6.apps.googleusercontent.com';

  /// LINE Official Account URL (official shortlink from LINE OA: https://lin.ee/9ENF0Wl -> @855szpwc)
  static const String lineOaUrl = 'https://lin.ee/9ENF0Wl';

  /// LINE Official Account Basic ID
  static const String lineOaBasicId = '@855szpwc';

  /// LINE Official Account QR Code Asset
  static const String lineOaQrAsset = 'assets/images/line_oa_qr.png';

  /// App Name & Tagline
  static const String appName = 'Rels Reading';
  static const String appTagline = 'คลังนิยายและการอ่านระดับพรีเมียม';

  /// Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
