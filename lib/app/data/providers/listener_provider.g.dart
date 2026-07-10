// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listener_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ListenerConnected)
final listenerConnectedProvider = ListenerConnectedProvider._();

final class ListenerConnectedProvider
    extends $AsyncNotifierProvider<ListenerConnected, bool> {
  ListenerConnectedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listenerConnectedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listenerConnectedHash();

  @$internal
  @override
  ListenerConnected create() => ListenerConnected();
}

String _$listenerConnectedHash() => r'440dbc8143ee5477e9c57335bb225e7033f23653';

abstract class _$ListenerConnected extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
