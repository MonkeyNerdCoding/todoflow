
part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorCode: json['colorCode'] as String,
      iconName: json['iconName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'colorCode': instance.colorCode,
      'iconName': instance.iconName,
      'createdAt': instance.createdAt.toIso8601String(),
      'taskCount': instance.taskCount,
      'isActive': instance.isActive,
    };
