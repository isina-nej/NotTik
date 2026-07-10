import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Primary Indigo
        brightness: Brightness.light,
        surface: const Color(0xFFF1F5F9), // Lighter iOS background
        surfaceContainerHigh: const Color(0xFFE2E8F0),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), // iOS style gray background
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      fontFamily: 'Vazirmatn', // Persian font
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF818CF8), // Lighter Indigo for Dark
        brightness: Brightness.dark,
        surface: const Color(0xFF000000), // Pure black for iOS dark mode
        surfaceContainerHigh: const Color(0xFF1C1C1E), // iOS Dark gray surface
      ),
      scaffoldBackgroundColor: const Color(0xFF000000), // Pitch black background
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      fontFamily: 'Vazirmatn',
    );
  }
}

// iOS-Style Glassmorphism Helper
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.blur = 20, // High blur for iOS effect
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // iOS Frosted Glass colors
    final glassColor = isDark 
        ? Colors.white.withOpacity(0.05) 
        : Colors.white.withOpacity(0.6);
        
    final borderColor = isDark 
        ? Colors.white.withOpacity(0.1) 
        : Colors.white.withOpacity(0.4);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24), // Highly rounded corners
      child: BackdropFilter(
        filter: dart_ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
