import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/providers/tasks_providers.dart';

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailProvider(taskId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de tarea')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (task) => _DetailBody(task: task),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Estado: ${task.status.wire}'),
        Text('Prioridad: ${task.priority.wire}'),
        Text('Asignado a: ${task.assignee}'),
        Text('Vence: ${task.dueDate.toLocal()}'),
        if (task.description != null) ...[
          const SizedBox(height: 8),
          Text(task.description!),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(tasksNotifierProvider.notifier).toggleStatus(task),
              child: Text(
                task.status == TaskStatus.hexa
                    ? 'Marcar pendiente'
                    : 'Marcar hecha',
              ),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(tasksNotifierProvider.notifier).deleteTask(task);
                if (context.mounted) {
                  context.pop();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ],
    );
  }
}
