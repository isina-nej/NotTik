// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationDetail)
final notificationDetailProvider = NotificationDetailFamily._();

final class NotificationDetailProvider
    extends
        $AsyncNotifierProvider<
          NotificationDetail,
          List<NativeNotificationRevision>
        > {
  NotificationDetailProvider._({
    required NotificationDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'notificationDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationDetailHash();

  @override
  String toString() {
    return r'notificationDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NotificationDetail create() => NotificationDetail();

  @override
  bool operator ==(Object other) {
    return other is NotificationDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationDetailHash() =>
    r'2723f922805ae0e1d64afc43b89db9c967694342';

final class NotificationDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          NotificationDetail,
          AsyncValue<List<NativeNotificationRevision>>,
          List<NativeNotificationRevision>,
          FutureOr<List<NativeNotificationRevision>>,
          int
        > {
  NotificationDetailFamily._()
    : super(
        retry: null,
        name: r'notificationDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationDetailProvider call(int recordId) =>
      NotificationDetailProvider._(argument: recordId, from: this);

  @override
  String toString() => r'notificationDetailProvider';
}

abstract class _$NotificationDetail
    extends $AsyncNotifier<List<NativeNotificationRevision>> {
  late final _$args = ref.$arg as int;
  int get recordId => _$args;

  FutureOr<List<NativeNotificationRevision>> build(int recordId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NativeNotificationRevision>>,
              List<NativeNotificationRevision>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NativeNotificationRevision>>,
                List<NativeNotificationRevision>
              >,
              AsyncValue<List<NativeNotificationRevision>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
