import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nottik/app/ui/screens/onboarding_screen.dart';
import 'package:nottik/app/ui/screens/history_screen.dart';
import 'package:nottik/app/ui/screens/detail_screen.dart';
import 'package:nottik/app/ui/screens/apps_screen.dart';
import 'package:nottik/app/ui/screens/settings_screen.dart';
import 'package:nottik/app/ui/screens/about_screen.dart';
import 'package:nottik/app/ui/screens/shell_scaffold.dart';
import 'package:nottik/app/data/providers/listener_provider.dart';
import 'package:nottik/app/bridge/pigeon.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final isConnected = ref.watch(listenerConnectedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (isConnected.isLoading) return null;

      final connected = isConnected.value ?? false;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!connected && !isGoingToOnboarding) {
        return '/onboarding';
      }
      if (connected && isGoingToOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/apps',
            builder: (context, state) => const AppsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final record = state.extra as NativeNotificationRecord;
          return DetailScreen(record: record);
        },
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  );
}
