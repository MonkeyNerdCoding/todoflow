// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Todo _$TodoFromJson(Map<String, dynamic> json) {
  return _Todo.fromJson(json);
}

_$TodoImpl _$$TodoImplFromJson(Map<String, dynamic> json) => _$TodoImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  categoryId: json['categoryId'] as String,
  priority:
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
      Priority.medium,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  dueTime: json['dueTime'] == null
      ? null
      : DateTime.parse(json['dueTime'] as String),
  isCompleted: json['isCompleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

/// @nodoc
mixin _$Todo {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  DateTime? get dueTime => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  List<Subtask> get subtasks => throw _privateConstructorUsedError;

  /// Serializes this Todo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoCopyWith<Todo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoCopyWith<$Res> {
  factory $TodoCopyWith(Todo value, $Res Function(Todo) then) =
      _$TodoCopyWithImpl<$Res, Todo>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String categoryId,
    Priority priority,
    DateTime? dueDate,
    DateTime? dueTime,
    bool isCompleted,
    DateTime createdAt,
    DateTime? completedAt,
    List<Subtask> subtasks,
  });
}

/// @nodoc
class _$TodoCopyWithImpl<$Res, $Val extends Todo>
    implements $TodoCopyWith<$Res> {
  _$TodoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? categoryId = null,
    Object? priority = null,
    Object? dueDate = freezed,
    Object? dueTime = freezed,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? subtasks = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as Priority,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dueTime: freezed == dueTime
                ? _value.dueTime
                : dueTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            subtasks: null == subtasks
                ? _value.subtasks
                : subtasks // ignore: cast_nullable_to_non_nullable
                      as List<Subtask>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoImplCopyWith<$Res> implements $TodoCopyWith<$Res> {
  factory _$$TodoImplCopyWith(
    _$TodoImpl value,
    $Res Function(_$TodoImpl) then,
  ) = __$$TodoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String categoryId,
    Priority priority,
    DateTime? dueDate,
    DateTime? dueTime,
    bool isCompleted,
    DateTime createdAt,
    DateTime? completedAt,
    List<Subtask> subtasks,
  });
}

/// @nodoc
class __$$TodoImplCopyWithImpl<$Res>
    extends _$TodoCopyWithImpl<$Res, _$TodoImpl>
    implements _$$TodoImplCopyWith<$Res> {
  __$$TodoImplCopyWithImpl(_$TodoImpl _value, $Res Function(_$TodoImpl) _then)
    : super(_value, _then);

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? categoryId = null,
    Object? priority = null,
    Object? dueDate = freezed,
    Object? dueTime = freezed,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? subtasks = null,
  }) {
    return _then(
      _$TodoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as Priority,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueTime: freezed == dueTime
            ? _value.dueTime
            : dueTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        subtasks: null == subtasks
            ? _value._subtasks
            : subtasks // ignore: cast_nullable_to_non_nullable
                  as List<Subtask>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TodoImpl implements _Todo {
  const _$TodoImpl({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    this.priority = Priority.medium,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    final List<Subtask> subtasks = const [],
  }) : _subtasks = subtasks;

  factory _$TodoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodoImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String categoryId;
  @override
  @JsonKey()
  final Priority priority;
  @override
  final DateTime? dueDate;
  @override
  final DateTime? dueTime;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;
  final List<Subtask> _subtasks;
  @override
  @JsonKey()
  List<Subtask> get subtasks {
    if (_subtasks is EqualUnmodifiableListView) return _subtasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtasks);
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, description: $description, categoryId: $categoryId, priority: $priority, dueDate: $dueDate, dueTime: $dueTime, isCompleted: $isCompleted, createdAt: $createdAt, completedAt: $completedAt, subtasks: $subtasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.dueTime, dueTime) || other.dueTime == dueTime) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            const DeepCollectionEquality().equals(other._subtasks, _subtasks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    categoryId,
    priority,
    dueDate,
    dueTime,
    isCompleted,
    createdAt,
    completedAt,
    const DeepCollectionEquality().hash(_subtasks),
  );

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoImplCopyWith<_$TodoImpl> get copyWith =>
      __$$TodoImplCopyWithImpl<_$TodoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoImplToJson(this);
  }
}

abstract class _Todo implements Todo {
  const factory _Todo({
    required final String id,
    required final String title,
    final String? description,
    required final String categoryId,
    final Priority priority,
    final DateTime? dueDate,
    final DateTime? dueTime,
    final bool isCompleted,
    required final DateTime createdAt,
    final DateTime? completedAt,
    final List<Subtask> subtasks,
  }) = _$TodoImpl;

  factory _Todo.fromJson(Map<String, dynamic> json) = _$TodoImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get categoryId;
  @override
  Priority get priority;
  @override
  DateTime? get dueDate;
  @override
  DateTime? get dueTime;
  @override
  bool get isCompleted;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;
  @override
  List<Subtask> get subtasks;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoImplCopyWith<_$TodoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
