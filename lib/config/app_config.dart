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
    if (kDebugMode) {
      return localBaseUrl;
    }
    return remoteBaseUrl;
  }

  /// Google OAuth Client ID for Web / Sign In
  static const String googleClientId =
      '267211717334-bg6su72vc71oaaenjspuhtoq5gmfdrf6.apps.googleusercontent.com';

  /// LINE Official Account URL
  static const String lineOaUrl = 'https://line.me/R/ti/p/@relsreading';

  /// App Name & Tagline
  static const String appName = 'Rels Reading';
  static const String appTagline = 'คลังนิยายและการอ่านระดับพรีเมียม';

  /// Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
