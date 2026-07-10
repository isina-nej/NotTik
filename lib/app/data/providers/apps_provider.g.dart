// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apps_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppsManagement)
final appsManagementProvider = AppsManagementProvider._();

final class AppsManagementProvider
    extends $AsyncNotifierProvider<AppsManagement, List<NativeAppMetadata>> {
  AppsManagementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appsManagementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appsManagementHash();

  @$internal
  @override
  AppsManagement create() => AppsManagement();
}

String _$appsManagementHash() => r'015cf6ddc45b1eae8031aa5af213ea98512db03f';

abstract class _$AppsManagement
    extends $AsyncNotifier<List<NativeAppMetadata>> {
  FutureOr<List<NativeAppMetadata>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NativeAppMetadata>>,
              List<NativeAppMetadata>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NativeAppMetadata>>,
                List<NativeAppMetadata>
              >,
              AsyncValue<List<NativeAppMetadata>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
