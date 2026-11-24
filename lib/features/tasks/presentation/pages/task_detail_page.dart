import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile_flutter/core/widgets/widgets.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/providers/tasks_providers.dart';

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailProvider(taskId));
    return AppPageScaffold(
      title: 'Detalle de tarea',
      body: state.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorView(message: 'Error: $error'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TaskStatusChip(status: task.status),
                  TaskPriorityChip(priority: task.priority),
                ],
              ),
              const SizedBox(height: 12),
              Text('Asignado a: ${task.assignee}'),
              Text('Vence: ${task.dueDate.toLocal()}'),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(task.description!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            AppButton(
              label: task.status == TaskStatus.hexa
                  ? 'Marcar pendiente'
                  : 'Marcar hecha',
              type: AppButtonType.secondary,
              icon: Icons.autorenew,
              onPressed: () =>
                  ref.read(tasksNotifierProvider.notifier).toggleStatus(task),
            ),
            AppButton(
              label: 'Editar',
              type: AppButtonType.secondary,
              icon: Icons.edit_outlined,
              onPressed: () => context.push('/tasks/${task.id}/edit'),
            ),
            AppButton(
              label: 'Eliminar',
              type: AppButtonType.danger,
              icon: Icons.delete_outline,
              onPressed: () => _confirmDelete(context, ref, task),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(tasksNotifierProvider.notifier).deleteTask(task);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}
