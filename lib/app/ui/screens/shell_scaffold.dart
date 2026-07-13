import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/apps')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final scheme = Theme.of(context).colorScheme;

    Widget navIcon(IconData data, Color color, {required bool selected}) {
      return DepthIcon(
        icon: data,
        color: color,
        size: selected ? 34 : 30,
        iconSize: selected ? 18 : 16,
        selected: selected,
      );
    }

    final tabs = <GlassTab>[
      GlassTab(
        icon: navIcon(Icons.history_rounded, scheme.primary, selected: false),
        activeIcon: navIcon(
          Icons.history_rounded,
          scheme.primary,
          selected: true,
        ),
        label: l10n.historyTitle,
        glowColor: scheme.primary,
      ),
      GlassTab(
        icon: navIcon(Icons.apps_rounded, scheme.secondary, selected: false),
        activeIcon: navIcon(
          Icons.apps_rounded,
          scheme.secondary,
          selected: true,
        ),
        label: l10n.appsTitle,
        glowColor: scheme.secondary,
      ),
      GlassTab(
        icon: navIcon(Icons.settings_rounded, scheme.tertiary, selected: false),
        activeIcon: navIcon(
          Icons.settings_rounded,
          scheme.tertiary,
          selected: true,
        ),
        label: l10n.settingsTitle,
        glowColor: scheme.tertiary,
      ),
    ];

    final paths = ['/', '/apps', '/settings'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: AppAmbientBackground()),
          child,
        ],
      ),
      bottomNavigationBar: GlassTabBar.bottom(
        tabs: tabs,
        selectedIndex: index,
        onTabSelected: (i) => context.go(paths[i]),
        barHeight: 72,
        horizontalPadding: 16,
        verticalPadding: 10,
        iconSize: 34,
        quality: GlassQuality.standard,
        selectedLabelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        settings: const LiquidGlassSettings(
          thickness: 28,
          blur: 8,
          refractiveIndex: 1.5,
        ),
      ),
    );
  }
}
