import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;
  final bool showGlow;
  final bool showBorder;

  const AppLogo({
    super.key,
    this.size = 64,
    this.borderRadius,
    this.showGlow = true,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? (size * 0.26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.35),
                  blurRadius: size * 0.25,
                  spreadRadius: size * 0.03,
                  offset: Offset(0, size * 0.08),
                ),
                BoxShadow(
                  color: AppTheme.secondary.withOpacity(0.2),
                  blurRadius: size * 0.35,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: showBorder
            ? Border.all(
                color: AppTheme.secondary.withOpacity(0.5),
                width: size > 40 ? 1.5 : 1.0,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(effectiveRadius),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: size * 0.55,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
