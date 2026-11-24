// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskDto _$TaskDtoFromJson(Map<String, dynamic> json) => _TaskDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: _statusFromJson(json['status']),
  priority: _priorityFromJson(json['priority']),
  assignee: json['assignee'] as String,
  dueDate: _dateTimeFromJson(json['dueDate']),
  createdAt: _dateTimeFromJson(json['createdAt']),
  updatedAt: _dateTimeFromJson(json['updatedAt']),
);

Map<String, dynamic> _$TaskDtoToJson(_TaskDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': _statusToJson(instance.status),
  'priority': _priorityToJson(instance.priority),
  'assignee': instance.assignee,
  'dueDate': _dateTimeToJson(instance.dueDate),
  'createdAt': _dateTimeToJson(instance.createdAt),
  'updatedAt': _dateTimeToJson(instance.updatedAt),
};

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] == null
          ? TaskStatus.pendiente
          : _statusFromJson(json['status']),
      priority: json['priority'] == null
          ? TaskPriority.media
          : _priorityFromJson(json['priority']),
      assignee: json['assignee'] as String,
      dueDate: _dateTimeFromJson(json['dueDate']),
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'status': _statusToJson(instance.status),
      'priority': _priorityToJson(instance.priority),
      'assignee': instance.assignee,
      'dueDate': _dateTimeToJson(instance.dueDate),
    };

_UpdateTaskRequest _$UpdateTaskRequestFromJson(Map<String, dynamic> json) =>
    _UpdateTaskRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: _nullableStatusFromJson(json['status']),
      priority: _nullablePriorityFromJson(json['priority']),
      assignee: json['assignee'] as String?,
      dueDate: _nullableDateTimeFromJson(json['dueDate']),
    );

Map<String, dynamic> _$UpdateTaskRequestToJson(_UpdateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'status': _nullableStatusToJson(instance.status),
      'priority': _nullablePriorityToJson(instance.priority),
      'assignee': instance.assignee,
      'dueDate': _nullableDateTimeToJson(instance.dueDate),
    };

_PageMeta _$PageMetaFromJson(Map<String, dynamic> json) => _PageMeta(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  lastPage: (json['lastPage'] as num).toInt(),
);

Map<String, dynamic> _$PageMetaToJson(_PageMeta instance) => <String, dynamic>{
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'lastPage': instance.lastPage,
};

_PaginatedTasksResponse _$PaginatedTasksResponseFromJson(
  Map<String, dynamic> json,
) => _PaginatedTasksResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PageMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaginatedTasksResponseToJson(
  _PaginatedTasksResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

_ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    _ErrorResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      error: json['error'] as String,
      message: json['message'],
      timestamp: _dateTimeFromJson(json['timestamp']),
      path: json['path'] as String,
    );

Map<String, dynamic> _$ErrorResponseToJson(_ErrorResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'error': instance.error,
      'message': instance.message,
      'timestamp': _dateTimeToJson(instance.timestamp),
      'path': instance.path,
    };
