import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_logo.dart';
import '../providers/auth_provider.dart';
import '../providers/novel_provider.dart';
import '../providers/bookmark_provider.dart';
import 'main_nav_screen.dart';
import 'novel/novel_detail_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? targetRoute;
  const SplashScreen({super.key, this.targetRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    final novelProvider = context.read<NovelProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();

    await Future.wait([
      authProvider.init(),
      novelProvider.fetchNovels(),
      bookmarkProvider.fetchBookmarks(),
      Future.delayed(const Duration(milliseconds: 400)), // Snappy transition delay
    ]);

    if (!mounted) return;

    if (widget.targetRoute != null && widget.targetRoute != '/' && widget.targetRoute!.isNotEmpty) {
      final uri = Uri.tryParse(widget.targetRoute!);
      final segments = uri?.pathSegments ?? [];

      // /novels/:id or /novel/:id
      if (segments.length >= 2 && (segments[0] == 'novels' || segments[0] == 'novel')) {
        final novelId = segments[1];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NovelDetailScreen(novelId: novelId)),
        );
        return;
      }

      // /community or /notifications
      if (segments.isNotEmpty && (segments[0] == 'community' || segments[0] == 'notifications')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 3)),
        );
        return;
      }

      // /missions
      if (segments.isNotEmpty && segments[0] == 'missions') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 1)),
        );
        return;
      }

      // /author or /dashboard
      if (segments.isNotEmpty && (segments[0] == 'author' || segments[0] == 'dashboard')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 2)),
        );
        return;
      }

      // /profile
      if (segments.isNotEmpty && segments[0] == 'profile') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 4)),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Official glowing app logo
                const AppLogo(size: 110, showGlow: true),
                const SizedBox(height: 28),
                Text(
                  AppConfig.appName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConfig.appTagline,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Text(
                      'กำลังเชื่อมต่อไปยังเซิร์ฟเวอร์...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
