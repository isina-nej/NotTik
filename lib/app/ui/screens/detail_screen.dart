import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/data/providers/detail_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:intl/intl.dart';

class DetailScreen extends ConsumerWidget {
  final NativeNotificationRecord record;

  const DetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revisionsAsync = ref.watch(notificationDetailProvider(record.id ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(record.appName ?? record.packageName ?? 'Details'),
      ),
      body: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphismCard(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.notifications_active, 
                        color: Theme.of(context).colorScheme.onPrimaryContainer, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.appName ?? record.packageName ?? 'Unknown App',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (record.groupKey != null) ...[
                          const SizedBox(height: 4),
                          Text('Group: ${record.groupKey}', 
                            style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(),
          
          // Revisions Timeline
          Expanded(
            child: revisionsAsync.when(
              data: (revisions) {
                if (revisions.isEmpty) {
                  return const Center(child: Text('هیچ تغییراتی یافت نشد.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: revisions.length,
                  itemBuilder: (context, index) {
                    final rev = revisions[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(rev.captureTimestamp ?? 0);
                    final timeStr = DateFormat.Hms().format(date);
                    final dateStr = DateFormat.yMd().format(date);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassmorphismCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (rev.title != null && rev.title!.isNotEmpty)
                              Text(rev.title!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            if (rev.text != null && rev.text!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(rev.text!),
                              ),
                            if (rev.bigText != null && rev.bigText!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(rev.bigText!, style: const TextStyle(fontStyle: FontStyle.italic)),
                              ),
                            
                            // Progress bar if available
                            if (rev.progressMax != null && rev.progressMax! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: LinearProgressIndicator(
                                  value: (rev.progressIndeterminate == true) 
                                      ? null 
                                      : (rev.progressValue?.toDouble() ?? 0) / (rev.progressMax?.toDouble() ?? 1),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطا: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
