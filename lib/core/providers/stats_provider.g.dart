// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentTodosHash() => r'400c8a017aa0f47c0e88d10f4562686c3bd6b317';

/// See also [recentTodos].
@ProviderFor(recentTodos)
final recentTodosProvider = AutoDisposeFutureProvider<List<Todo>>.internal(
  recentTodos,
  name: r'recentTodosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentTodosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentTodosRef = AutoDisposeFutureProviderRef<List<Todo>>;
String _$searchTodosHash() => r'dc1a2fc37e07afb688a10b7c870889bb4ffcadaa';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [searchTodos].
@ProviderFor(searchTodos)
const searchTodosProvider = SearchTodosFamily();

/// See also [searchTodos].
class SearchTodosFamily extends Family<AsyncValue<List<Todo>>> {
  /// See also [searchTodos].
  const SearchTodosFamily();

  /// See also [searchTodos].
  SearchTodosProvider call(String query) {
    return SearchTodosProvider(query);
  }

  @override
  SearchTodosProvider getProviderOverride(
    covariant SearchTodosProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchTodosProvider';
}

/// See also [searchTodos].
class SearchTodosProvider extends AutoDisposeFutureProvider<List<Todo>> {
  /// See also [searchTodos].
  SearchTodosProvider(String query)
    : this._internal(
        (ref) => searchTodos(ref as SearchTodosRef, query),
        from: searchTodosProvider,
        name: r'searchTodosProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchTodosHash,
        dependencies: SearchTodosFamily._dependencies,
        allTransitiveDependencies: SearchTodosFamily._allTransitiveDependencies,
        query: query,
      );

  SearchTodosProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Todo>> Function(SearchTodosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchTodosProvider._internal(
        (ref) => create(ref as SearchTodosRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Todo>> createElement() {
    return _SearchTodosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTodosProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchTodosRef on AutoDisposeFutureProviderRef<List<Todo>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchTodosProviderElement
    extends AutoDisposeFutureProviderElement<List<Todo>>
    with SearchTodosRef {
  _SearchTodosProviderElement(super.provider);

  @override
  String get query => (origin as SearchTodosProvider).query;
}

String _$todoStatsHash() => r'e8fb28c3feb471eda91362401d27dd515ab2280c';

/// See also [TodoStats].
@ProviderFor(TodoStats)
final todoStatsProvider =
    AutoDisposeAsyncNotifierProvider<TodoStats, TodoStatsData>.internal(
      TodoStats.new,
      name: r'todoStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoStats = AutoDisposeAsyncNotifier<TodoStatsData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
