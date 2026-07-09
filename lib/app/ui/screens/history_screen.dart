import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/app/data/providers/listener_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isConnected = ref.watch(listenerConnectedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: isConnected.when(
        data: (connected) {
          if (!connected) {
            return Center(
              child: ElevatedButton(
                onPressed: () => ref.read(listenerConnectedProvider.notifier).openSettings(),
                child: Text(l10n.grantPermission),
              ),
            );
          }
          
          return Center(
            child: Text(l10n.emptyHistory),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}