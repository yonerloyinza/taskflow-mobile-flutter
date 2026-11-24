import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_priority.dart';
import 'task_status.dart';

part 'task_entity.freezed.dart';

@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String id,
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required String assignee,
    required DateTime dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskEntity;
}
