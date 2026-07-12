// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationHistory)
final notificationHistoryProvider = NotificationHistoryProvider._();

final class NotificationHistoryProvider
    extends
        $AsyncNotifierProvider<
          NotificationHistory,
          List<NativeNotificationRecord>
        > {
  NotificationHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationHistoryHash();

  @$internal
  @override
  NotificationHistory create() => NotificationHistory();
}

String _$notificationHistoryHash() =>
    r'a6c1c9e6123bc85f3174d09d5c1ed1dede8a65c4';

abstract class _$NotificationHistory
    extends $AsyncNotifier<List<NativeNotificationRecord>> {
  FutureOr<List<NativeNotificationRecord>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NativeNotificationRecord>>,
              List<NativeNotificationRecord>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NativeNotificationRecord>>,
                List<NativeNotificationRecord>
              >,
              AsyncValue<List<NativeNotificationRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
