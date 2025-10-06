// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubtaskImpl _$$SubtaskImplFromJson(Map<String, dynamic> json) =>
    _$SubtaskImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      parentTodoId: json['parentTodoId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );

Map<String, dynamic> _$$SubtaskImplToJson(_$SubtaskImpl instance) => {
      'id': instance.id,
      'title': instance.title,
      'parentTodoId': instance.parentTodoId,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.completedAt != null)
        'completedAt': instance.completedAt!.toIso8601String(),
    };
