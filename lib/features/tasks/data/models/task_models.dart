import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_models.freezed.dart';
part 'task_models.g.dart';

@JsonEnum()
enum TaskStatus {
  @JsonValue('pendiente')
  pendiente,
  @JsonValue('en_curso')
  enCurso,
  @JsonValue('hexa')
  hexa,
}

@JsonEnum()
enum TaskPriority {
  @JsonValue('baja')
  baja,
  @JsonValue('media')
  media,
  @JsonValue('alta')
  alta,
}

extension TaskStatusX on TaskStatus {
  String get wire => switch (this) {
    TaskStatus.pendiente => 'pendiente',
    TaskStatus.enCurso => 'en_curso',
    TaskStatus.hexa => 'hexa',
  };

  static TaskStatus? fromWire(String? value) => switch (value) {
    'pendiente' => TaskStatus.pendiente,
    'en_curso' => TaskStatus.enCurso,
    'hexa' => TaskStatus.hexa,
    _ => null,
  };
}

extension TaskPriorityX on TaskPriority {
  String get wire => switch (this) {
    TaskPriority.baja => 'baja',
    TaskPriority.media => 'media',
    TaskPriority.alta => 'alta',
  };

  static TaskPriority? fromWire(String? value) => switch (value) {
    'baja' => TaskPriority.baja,
    'media' => TaskPriority.media,
    'alta' => TaskPriority.alta,
    _ => null,
  };
}

@freezed
abstract class TaskDto with _$TaskDto {
  const factory TaskDto({
    required String id,
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required String assignee,
    required DateTime dueDate,
    required DateTime createdAt,
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
    @Default(TaskStatus.pendiente) TaskStatus status,
    @Default(TaskPriority.media) TaskPriority priority,
    required String assignee,
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
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
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
    required DateTime timestamp,
    required String path,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
