import 'package:taskflow_mobile_flutter/core/database/app_database.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';

TaskDto rowToDto(TaskRow row) {
  return TaskDto(
    id: row.id,
    title: row.title,
    description: row.description,
    status: TaskStatusX.fromWire(row.status) ?? TaskStatus.pendiente,
    priority: TaskPriorityX.fromWire(row.priority) ?? TaskPriority.media,
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
