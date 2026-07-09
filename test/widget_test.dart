import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/main.dart';
import 'package:nottik/app/data/providers/listener_provider.dart';

void main() {
  testWidgets('NotTik App launches and shows onboarding if no connection', (WidgetTester tester) async {
    
    // Create a mock provider that returns false (disconnected)
    final container = ProviderScope(
      overrides: [
        listenerConnectedProvider.overrideWith(() => MockListenerConnectedFalse()),
      ],
      child: const NotTikApp(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(container);

    // Ensure animations and navigation settles
    await tester.pumpAndSettle();

    // Verify that Onboarding Screen is shown by looking for the onboarding icon
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
  });
  
  testWidgets('NotTik App launches History if connection is present', (WidgetTester tester) async {
    
    // Create a mock provider that returns true (connected)
    final container = ProviderScope(
      overrides: [
        listenerConnectedProvider.overrideWith(() => MockListenerConnectedTrue()),
      ],
      child: const NotTikApp(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(container);
    await tester.pumpAndSettle();

    // Verify that History Screen is shown
    expect(find.byIcon(Icons.settings), findsOneWidget); // settings icon on history appbar
  });
}

class MockListenerConnectedFalse extends ListenerConnected {
  @override
  Future<bool> build() async => false;
}

class MockListenerConnectedTrue extends ListenerConnected {
  @override
  Future<bool> build() async => true;
}