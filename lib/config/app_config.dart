class AppConfig {
  /// Base URL of the deployed backend on Vercel
  static const String baseUrl = 'https://backend-gamma-ten-81.vercel.app/api';

  /// App Name
  static const String appName = 'Rels Reading';
  static const String appTagline = 'คลังนิยายและการอ่านระดับพรีเมียม';

  /// Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
