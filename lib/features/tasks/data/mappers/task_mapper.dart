import 'package:taskflow_mobile_flutter/core/database/app_database.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

TaskDto entityToDto(TaskEntity entity) {
  return TaskDto(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    status: entity.status,
    priority: entity.priority,
    assignee: entity.assignee,
    dueDate: entity.dueDate,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}

TaskEntity dtoToEntity(TaskDto dto) {
  return TaskEntity(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    status: dto.status,
    priority: dto.priority,
    assignee: dto.assignee,
    dueDate: dto.dueDate,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );
}

TaskDto rowToDto(TaskRow row) {
  return TaskDto(
    id: row.id,
    title: row.title,
    description: row.description,
    status: TaskStatusX.tryFromWire(row.status) ?? TaskStatus.pendiente,
    priority: TaskPriorityX.tryFromWire(row.priority) ?? TaskPriority.media,
    assignee: row.assignee,
    dueDate: row.dueDate,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

TaskRow dtoToRow(
  TaskDto dto, {
  bool synced = true,
  bool deleted = false,
  DateTime? updatedAt,
}) {
  return TaskRow(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    status: dto.status.wire,
    priority: dto.priority.wire,
    assignee: dto.assignee,
    dueDate: dto.dueDate,
    createdAt: dto.createdAt,
    updatedAt: updatedAt ?? dto.updatedAt,
    synced: synced,
    deleted: deleted,
  );
}
