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
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$SubtaskImplToJson(_$SubtaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'parentTodoId': instance.parentTodoId,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
