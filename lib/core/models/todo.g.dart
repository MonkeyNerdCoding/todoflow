// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

Map<String, dynamic> _$$TodoImplToJson(_$TodoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'dueDate': instance.dueDate?.toIso8601String(),
      'dueTime': instance.dueTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'subtasks': instance.subtasks,
    };

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
};
