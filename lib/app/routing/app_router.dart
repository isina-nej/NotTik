import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nottik/app/ui/screens/onboarding_screen.dart';
import 'package:nottik/app/ui/screens/history_screen.dart';
import 'package:nottik/app/data/providers/listener_provider.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final isListenerConnected = ref.watch(listenerConnectedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If the listener is not connected, redirect to onboarding.
      // We will only do this once the provider resolves its async state.
      if (isListenerConnected.valueOrNull == false && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      
      // If connected and trying to go to onboarding, go to history instead
      if (isListenerConnected.valueOrNull == true && state.matchedLocation == '/onboarding') {
        return '/';
      }
      
      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}