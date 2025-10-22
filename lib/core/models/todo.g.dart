
part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************



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
