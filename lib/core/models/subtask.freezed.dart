// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subtask _$SubtaskFromJson(Map<String, dynamic> json) {
  return _Subtask.fromJson(json);
}

/// @nodoc
mixin _$Subtask {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get parentTodoId => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this Subtask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subtask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtaskCopyWith<Subtask> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtaskCopyWith<$Res> {
  factory $SubtaskCopyWith(Subtask value, $Res Function(Subtask) then) =
      _$SubtaskCopyWithImpl<$Res, Subtask>;
  @useResult
  $Res call({
    String id,
    String title,
    String parentTodoId,
    bool isCompleted,
    DateTime createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$SubtaskCopyWithImpl<$Res, $Val extends Subtask>
    implements $SubtaskCopyWith<$Res> {
  _$SubtaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subtask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? parentTodoId = null,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
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
            parentTodoId: null == parentTodoId
                ? _value.parentTodoId
                : parentTodoId // ignore: cast_nullable_to_non_nullable
                      as String,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubtaskImplCopyWith<$Res> implements $SubtaskCopyWith<$Res> {
  factory _$$SubtaskImplCopyWith(
    _$SubtaskImpl value,
    $Res Function(_$SubtaskImpl) then,
  ) = __$$SubtaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String parentTodoId,
    bool isCompleted,
    DateTime createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$SubtaskImplCopyWithImpl<$Res>
    extends _$SubtaskCopyWithImpl<$Res, _$SubtaskImpl>
    implements _$$SubtaskImplCopyWith<$Res> {
  __$$SubtaskImplCopyWithImpl(
    _$SubtaskImpl _value,
    $Res Function(_$SubtaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subtask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? parentTodoId = null,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$SubtaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        parentTodoId: null == parentTodoId
            ? _value.parentTodoId
            : parentTodoId // ignore: cast_nullable_to_non_nullable
                  as String,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtaskImpl implements _Subtask {
  const _$SubtaskImpl({
    required this.id,
    required this.title,
    required this.parentTodoId,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory _$SubtaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String parentTodoId;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'Subtask(id: $id, title: $title, parentTodoId: $parentTodoId, isCompleted: $isCompleted, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.parentTodoId, parentTodoId) ||
                other.parentTodoId == parentTodoId) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    parentTodoId,
    isCompleted,
    createdAt,
    completedAt,
  );

  /// Create a copy of Subtask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtaskImplCopyWith<_$SubtaskImpl> get copyWith =>
      __$$SubtaskImplCopyWithImpl<_$SubtaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtaskImplToJson(this);
  }
}

abstract class _Subtask implements Subtask {
  const factory _Subtask({
    required final String id,
    required final String title,
    required final String parentTodoId,
    final bool isCompleted,
    required final DateTime createdAt,
    final DateTime? completedAt,
  }) = _$SubtaskImpl;

  factory _Subtask.fromJson(Map<String, dynamic> json) = _$SubtaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get parentTodoId;
  @override
  bool get isCompleted;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of Subtask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtaskImplCopyWith<_$SubtaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
