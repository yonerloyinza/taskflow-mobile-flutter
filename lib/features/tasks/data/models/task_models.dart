import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

part 'task_models.freezed.dart';
part 'task_models.g.dart';

TaskStatus _statusFromJson(Object? json) =>
    TaskStatusX.fromWire(json! as String);

TaskStatus? _nullableStatusFromJson(Object? json) =>
    json == null ? null : TaskStatusX.fromWire(json as String);

Object? _statusToJson(TaskStatus status) => status.wire;

Object? _nullableStatusToJson(TaskStatus? status) => status?.wire;

TaskPriority _priorityFromJson(Object? json) =>
    TaskPriorityX.fromWire(json! as String);

TaskPriority? _nullablePriorityFromJson(Object? json) =>
    json == null ? null : TaskPriorityX.fromWire(json as String);

Object? _priorityToJson(TaskPriority priority) => priority.wire;

Object? _nullablePriorityToJson(TaskPriority? priority) => priority?.wire;

DateTime _dateTimeFromJson(Object? json) => DateTime.parse(json! as String);

DateTime? _nullableDateTimeFromJson(Object? json) =>
    json == null ? null : DateTime.parse(json as String);

Object? _dateTimeToJson(DateTime value) => value.toUtc().toIso8601String();

Object? _nullableDateTimeToJson(DateTime? value) =>
    value?.toUtc().toIso8601String();

@freezed
abstract class TaskDto with _$TaskDto {
  const factory TaskDto({
    required String id,
    required String title,
    String? description,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required TaskStatus status,
    @JsonKey(fromJson: _priorityFromJson, toJson: _priorityToJson)
    required TaskPriority priority,
    required String assignee,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime dueDate,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime updatedAt,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
}

@freezed
abstract class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required String title,
    String? description,
    @Default(TaskStatus.pendiente)
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    TaskStatus status,
    @Default(TaskPriority.media)
    @JsonKey(fromJson: _priorityFromJson, toJson: _priorityToJson)
    TaskPriority priority,
    required String assignee,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime dueDate,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}

@freezed
abstract class UpdateTaskRequest with _$UpdateTaskRequest {
  const factory UpdateTaskRequest({
    String? title,
    String? description,
    @JsonKey(fromJson: _nullableStatusFromJson, toJson: _nullableStatusToJson)
    TaskStatus? status,
    @JsonKey(
      fromJson: _nullablePriorityFromJson,
      toJson: _nullablePriorityToJson,
    )
    TaskPriority? priority,
    String? assignee,
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    DateTime? dueDate,
  }) = _UpdateTaskRequest;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);
}

@freezed
abstract class PageMeta with _$PageMeta {
  const factory PageMeta({
    required int total,
    required int page,
    required int limit,
    required int lastPage,
  }) = _PageMeta;

  factory PageMeta.fromJson(Map<String, dynamic> json) =>
      _$PageMetaFromJson(json);
}

@freezed
abstract class PaginatedTasksResponse with _$PaginatedTasksResponse {
  const factory PaginatedTasksResponse({
    required List<TaskDto> data,
    required PageMeta meta,
  }) = _PaginatedTasksResponse;

  factory PaginatedTasksResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedTasksResponseFromJson(json);
}

@freezed
abstract class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    required int statusCode,
    required String error,
    required Object? message,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime timestamp,
    required String path,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
