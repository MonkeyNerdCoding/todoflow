// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredTodosHash() => r'1c580611eccf0207ad56ac05ea9ecdfdff78f740';

/// See also [filteredTodos].
@ProviderFor(filteredTodos)
final filteredTodosProvider = AutoDisposeFutureProvider<List<Todo>>.internal(
  filteredTodos,
  name: r'filteredTodosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTodosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTodosRef = AutoDisposeFutureProviderRef<List<Todo>>;
String _$filterStateHash() => r'968be469556c2ac5004dcb8a53a706287c89678e';

/// See also [FilterState].
@ProviderFor(FilterState)
final filterStateProvider =
    AutoDisposeNotifierProvider<FilterState, TodoFilter>.internal(
      FilterState.new,
      name: r'filterStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filterStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FilterState = AutoDisposeNotifier<TodoFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
