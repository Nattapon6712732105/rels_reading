import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/novel_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/reader_settings_provider.dart';
import 'screens/splash_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Thai locale for DateFormat
  try {
    await initializeDateFormatting('th', null);
  } catch (e) {
    debugPrint('Date formatting init error: $e');
  }

  // Graceful ErrorWidget builder in release mode (avoids ugly grey box)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF151620),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF242636)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kDebugMode ? details.exceptionAsString() : 'ไม่สามารถโหลดข้อมูลส่วนนี้ได้ชั่วคราว',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  };

  // Initialize Dio API client and token interceptors
  ApiClient.init();

  // Optimized image cache configuration
  PaintingBinding.instance.imageCache.maximumSizeBytes = 128 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 250;

  // Initialize Google Sign-In on both Web and Mobile
  try {
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? AppConfig.googleClientId : null,
      serverClientId: AppConfig.googleClientId,
    );
  } catch (e) {
    debugPrint('Google Sign-In initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NovelProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ReaderSettingsProvider()),
      ],
      child: Consumer<ReaderSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.appThemeMode,
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (_) => SplashScreen(targetRoute: routeSettings.name),
                settings: routeSettings,
              );
            },
          );
        },
      ),
    );
  }
}
