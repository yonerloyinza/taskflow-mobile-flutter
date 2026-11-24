import 'package:flutter/material.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status});

  final TaskStatus status;

  static const Map<TaskStatus, String> _labels = {
    TaskStatus.pendiente: 'Pendiente',
    TaskStatus.enCurso: 'En curso',
    TaskStatus.hexa: 'Hecha',
  };

  static const Map<TaskStatus, IconData> _icons = {
    TaskStatus.pendiente: Icons.schedule,
    TaskStatus.enCurso: Icons.autorenew,
    TaskStatus.hexa: Icons.check_circle,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado: ${_labels[status]}',
      child: Chip(
        avatar: Icon(_icons[status], size: 16),
        label: Text(_labels[status]!),
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      ),
    );
  }
}

class TaskPriorityChip extends StatelessWidget {
  const TaskPriorityChip({super.key, required this.priority});

  final TaskPriority priority;

  static const Map<TaskPriority, String> _labels = {
    TaskPriority.baja: 'Baja',
    TaskPriority.media: 'Media',
    TaskPriority.alta: 'Alta',
  };

  static const Map<TaskPriority, IconData> _icons = {
    TaskPriority.baja: Icons.arrow_downward,
    TaskPriority.media: Icons.remove,
    TaskPriority.alta: Icons.arrow_upward,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Prioridad: ${_labels[priority]}',
      child: Chip(
        avatar: Icon(_icons[priority], size: 16),
        label: Text(_labels[priority]!),
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      ),
    );
  }
}
