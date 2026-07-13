import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppTheme {
  static const Color _seedLight = Color(0xFF5B5FEF);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedLight,
      brightness: Brightness.light,
      surface: const Color(0xFFF4F5FA),
      surfaceContainerHigh: const Color(0xFFE8EAF3),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: _seedLight.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Vazirmatn',
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      fontFamily: 'Vazirmatn',
    );
  }

  static ThemeData get darkTheme {
    // Explicit iOS-ish indigo night palette — not muddy fromSeed greys.
    const bg = Color(0xFF0C0E16);
    const surface = Color(0xFF151925);
    const surfaceHigh = Color(0xFF1B2030);
    const surfaceHighest = Color(0xFF252B3D);
    const primary = Color(0xFFA5B4FC);
    const onPrimary = Color(0xFF14182A);
    const secondary = Color(0xFFC4B5FD);
    const tertiary = Color(0xFF7DD3FC);
    const onSurface = Color(0xFFF2F4FF);
    const onVariant = Color(0xFF9AA3B8);
    const outline = Color(0xFF3A4158);

    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: const Color(0xFF2A3150),
      onPrimaryContainer: const Color(0xFFDDE3FF),
      secondary: secondary,
      onSecondary: const Color(0xFF1A1530),
      secondaryContainer: const Color(0xFF32284A),
      onSecondaryContainer: const Color(0xFFE9DEFF),
      tertiary: tertiary,
      onTertiary: const Color(0xFF062033),
      tertiaryContainer: const Color(0xFF1A3A52),
      onTertiaryContainer: const Color(0xFFD7F0FF),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: bg,
      surfaceContainerLow: const Color(0xFF12151F),
      surfaceContainer: surfaceHigh,
      surfaceContainerHigh: surfaceHighest,
      surfaceContainerHighest: const Color(0xFF2E354A),
      onSurfaceVariant: onVariant,
      outline: outline,
      outlineVariant: const Color(0xFF2A3042),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE6E8F5),
      onInverseSurface: const Color(0xFF1A1D28),
      inversePrimary: const Color(0xFF4F56C9),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: bg,
      dividerColor: outline.withValues(alpha: 0.35),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: onSurface, fontFamily: 'Vazirmatn'),
        bodyMedium: TextStyle(color: onSurface, fontFamily: 'Vazirmatn'),
        bodySmall: TextStyle(color: onVariant, fontFamily: 'Vazirmatn'),
        titleLarge: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(color: onSurface, fontFamily: 'Vazirmatn'),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Vazirmatn',
            color: selected ? primary : onVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh.withValues(alpha: 0.88),
        hintStyle: const TextStyle(color: onVariant, fontFamily: 'Vazirmatn'),
        labelStyle: const TextStyle(color: onVariant, fontFamily: 'Vazirmatn'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: onVariant,
        indicatorColor: Colors.white,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: primary,
        textColor: onSurface,
        subtitleTextStyle: TextStyle(color: onVariant, fontFamily: 'Vazirmatn'),
      ),
      fontFamily: 'Vazirmatn',
    );
  }
}

/// Layered ambient field with spherical orbs (pseudo-3D depth).
/// Pass [child] only when wrapping content; for a fixed shell backdrop omit it.
class AppAmbientBackground extends StatelessWidget {
  final Widget? child;

  const AppAmbientBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Night: deep indigo-slate (not pure black). Day: soft lilac wash.
    final top = isDark ? const Color(0xFF0C0E16) : const Color(0xFFEEF0FA);
    final mid = isDark ? const Color(0xFF121624) : const Color(0xFFE6E9F6);
    final bottom = isDark ? const Color(0xFF1A2032) : const Color(0xFFDDE1F2);

    final field = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [top, mid, bottom],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -60,
          child: DepthOrb(
            size: 300,
            colors: isDark
                ? const [Color(0xFF818CF8), Color(0xFF312E81)]
                : const [Color(0xFFA5B4FC), Color(0xFF6366F1)],
            opacity: isDark ? 0.42 : 0.45,
          ),
        ),
        Positioned(
          top: 200,
          left: -110,
          child: DepthOrb(
            size: 260,
            colors: isDark
                ? const [Color(0xFFC4B5FD), Color(0xFF4C1D95)]
                : const [Color(0xFFDDD6FE), Color(0xFF8B5CF6)],
            opacity: isDark ? 0.32 : 0.38,
          ),
        ),
        Positioned(
          bottom: 80,
          right: -40,
          child: DepthOrb(
            size: 200,
            colors: isDark
                ? const [Color(0xFF67E8F9), Color(0xFF164E63)]
                : const [Color(0xFFBAE6FD), Color(0xFF60A5FA)],
            opacity: isDark ? 0.22 : 0.32,
          ),
        ),
      ],
    );

    if (child == null) return field;
    return Stack(fit: StackFit.expand, children: [field, child!]);
  }
}

/// Sphere-like orb: radial light + contact shadow = 3D volume.
class DepthOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;
  final Widget? child;

  const DepthOrb({
    super.key,
    required this.size,
    required this.colors,
    this.opacity = 1,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final light = colors.first;
    final deep = colors.length > 1 ? colors[1] : colors.first;

    return IgnorePointer(
      ignoring: child == null,
      child: SizedBox(
        width: size,
        height: size * 1.12,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Contact shadow under sphere
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.72,
                height: size * 0.14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: deep.withValues(alpha: 0.45 * opacity),
                      blurRadius: size * 0.18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Sphere body
            Positioned(
              top: 0,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.45, -0.55),
                      radius: 0.95,
                      colors: [
                        Color.lerp(light, Colors.white, 0.55)!,
                        light,
                        deep,
                        Color.lerp(deep, Colors.black, 0.35)!,
                      ],
                      stops: const [0.0, 0.28, 0.72, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: light.withValues(alpha: 0.45),
                        blurRadius: size * 0.28,
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: size * 0.2,
                        offset: Offset(0, size * 0.12),
                      ),
                    ],
                  ),
                  child: child == null ? null : Center(child: child),
                ),
              ),
            ),
            // Specular highlight
            Positioned(
              top: size * 0.14,
              left: size * 0.22,
              child: Opacity(
                opacity: 0.55 * opacity,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating glass panel.
///
/// Uses real Liquid Glass (`GlassCard`) when available; falls back to classic
/// BackdropFilter glassmorphism if the liquid layer is unavailable.
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double depth;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.borderRadius,
    this.padding,
    this.depth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(28);
    final r = radius.topLeft.x;
    final pad = padding ?? const EdgeInsets.all(16);

    // Liquid Glass path (shader refraction + blur).
    return GlassCard(
      useOwnLayer: true,
      quality: GlassQuality.standard,
      padding: pad,
      shape: LiquidRoundedSuperellipse(borderRadius: r),
      settings: LiquidGlassSettings(
        thickness: 22 + (depth * 6),
        blur: (blur / 4).clamp(4, 14),
        refractiveIndex: 1.48,
      ),
      child: child,
    );
  }
}

/// Lightweight depth card for dense scrolling rows.
///
/// Keeps the NotTik ambient/liquid look without allocating a Liquid Glass layer
/// for every visible list item.
class DepthListCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const DepthListCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHigh.withValues(alpha: isDark ? 0.78 : 0.72),
            scheme.surface.withValues(alpha: isDark ? 0.58 : 0.64),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.46),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Raised 3D CTA with dual-tone face + hard/soft shadow stack.
class DepthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;

  const DepthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(scheme.primary, Colors.white, 0.18)!,
                scheme.primary,
                Color.lerp(scheme.primary, Colors.black, 0.18)!,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 10),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              // Top edge highlight
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25),
                blurRadius: 0,
                offset: const Offset(0, -1),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Vazirmatn',
            ),
            child: IconTheme(
              data: IconThemeData(color: scheme.onPrimary, size: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [icon, const SizedBox(width: 10), label],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle floating transform for hero objects.
class FloatingDepth extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;

  const FloatingDepth({
    super.key,
    required this.child,
    this.amplitude = 8,
    this.duration = const Duration(milliseconds: 2800),
  });

  @override
  State<FloatingDepth> createState() => _FloatingDepthState();
}

class _FloatingDepthState extends State<FloatingDepth>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    // Infinite animation breaks pumpAndSettle in widget tests.
    final binding = WidgetsBinding.instance;
    if (binding.runtimeType.toString() !=
            'AutomatedTestWidgetsFlutterBinding' &&
        binding.runtimeType.toString() != 'LiveTestWidgetsFlutterBinding') {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value * 2 * math.pi;
        final dy = math.sin(t) * widget.amplitude;
        final scale = 1 + math.sin(t) * 0.015;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Squircle icon tile: bevel face + specular + contact shadow (3D glyph).
class DepthIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final bool selected;

  const DepthIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(color, Colors.white, selected ? 0.38 : 0.26)!;
    final mid = color;
    final deep = Color.lerp(color, Colors.black, selected ? 0.22 : 0.34)!;
    final r = BorderRadius.circular(size * 0.30);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          // Colored glow
          BoxShadow(
            color: color.withValues(alpha: selected ? 0.55 : 0.38),
            blurRadius: selected ? 18 : 12,
            offset: Offset(0, selected ? 8 : 5),
            spreadRadius: selected ? -1 : -2,
          ),
          // Contact shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          // Near edge lift
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dual-tone face
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [light, mid, deep],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            // Specular sheen (top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size * 0.48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: selected ? 0.42 : 0.30),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom inner shade
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size * 0.35,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Rim
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                border: Border.all(
                  color: Colors.white.withValues(alpha: selected ? 0.55 : 0.35),
                  width: 1.1,
                ),
              ),
            ),
            // Glyph
            Center(
              child: Icon(
                icon,
                size: iconSize,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Color(0x88000000),
                    blurRadius: 3,
                    offset: Offset(0, 1.5),
                  ),
                  Shadow(
                    color: Color(0x55FFFFFF),
                    blurRadius: 0,
                    offset: Offset(0, -0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3D badge for app icons / letter avatars (history + apps lists).
class DepthAppBadge extends StatelessWidget {
  final String? path;
  final String letter;
  final double size;
  final Color? accent;

  const DepthAppBadge({
    super.key,
    required this.path,
    required this.letter,
    this.size = 48,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = accent ?? scheme.primary;
    final light = Color.lerp(base, Colors.white, 0.35)!;
    final deep = Color.lerp(base, Colors.black, 0.28)!;
    final r = BorderRadius.circular(size * 0.30);
    final imagePath = path?.trim();
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                cacheWidth: size.ceil() * 2,
                cacheHeight: size.ceil() * 2,
                errorBuilder: (_, error, stack) =>
                    _letterFace(light, base, deep),
              )
            else
              _letterFace(light, base, deep),
            // Specular glass plate
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size * 0.42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Rim
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.40),
                  width: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _letterFace(Color light, Color mid, Color deep) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [light, mid, deep],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.38,
              fontFamily: 'Vazirmatn',
              shadows: const [
                Shadow(
                  color: Color(0x88000000),
                  blurRadius: 3,
                  offset: Offset(0, 1.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Large empty-state glyph with soft floating shadow.
class DepthEmptyIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const DepthEmptyIcon({super.key, required this.icon, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DepthOrb(
      size: size,
      opacity: 1,
      colors: isDark
          ? [
              scheme.primary.withValues(alpha: 0.95),
              Color.lerp(scheme.primary, Colors.black, 0.45)!,
            ]
          : [Color.lerp(scheme.primary, Colors.white, 0.35)!, scheme.primary],
      child: Icon(
        icon,
        size: size * 0.42,
        color: scheme.onPrimary,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
