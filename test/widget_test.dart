import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/main.dart';
import 'package:nottik/app/data/providers/listener_provider.dart';
import 'package:nottik/app/data/providers/history_provider.dart';
import 'package:nottik/app/bridge/pigeon.dart';

void main() {
  testWidgets('NotTik App launches and shows onboarding if no connection', (
    WidgetTester tester,
  ) async {
    final container = ProviderScope(
      overrides: [
        listenerConnectedProvider.overrideWith(
          () => MockListenerConnectedFalse(),
        ),
        notificationHistoryProvider.overrideWith(
          () => MockNotificationHistory(),
        ),
      ],
      child: const NotTikApp(),
    );
    await tester.pumpWidget(container);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
  });

  testWidgets('NotTik App launches History if connection is present', (
    WidgetTester tester,
  ) async {
    final container = ProviderScope(
      overrides: [
        listenerConnectedProvider.overrideWith(
          () => MockListenerConnectedTrue(),
        ),
        notificationHistoryProvider.overrideWith(
          () => MockNotificationHistory(),
        ),
      ],
      child: const NotTikApp(),
    );
    await tester.pumpWidget(container);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    // Since history has no items, we should see the empty text
    expect(find.text('هیچ نوتیفیکیشنی یافت نشد.'), findsOneWidget);
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

class MockNotificationHistory extends NotificationHistory {
  @override
  Future<List<NativeNotificationRecord>> build() async => [];
}
