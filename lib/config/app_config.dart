class AppConfig {
  /// Base URL of the deployed backend on Vercel
  static const String baseUrl = 'https://backend-gamma-ten-81.vercel.app/api';

  /// Google OAuth Client ID for Web / Sign In
  static const String googleClientId =
      '267211717334-bg6su72vc71oaaenjspuhtoq5gmfdrf6.apps.googleusercontent.com';

  /// App Name
  static const String appName = 'Rels Reading';
  static const String appTagline = 'คลังนิยายและการอ่านระดับพรีเมียม';

  /// Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
