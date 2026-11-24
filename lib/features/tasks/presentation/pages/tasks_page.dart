import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile_flutter/app/providers.dart';
import 'package:taskflow_mobile_flutter/core/widgets/widgets.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/providers/tasks_notifier.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/providers/tasks_providers.dart';

String _statusLabel(TaskStatus status) => switch (status) {
  TaskStatus.pendiente => 'Pendiente',
  TaskStatus.enCurso => 'En curso',
  TaskStatus.hexa => 'Hecha',
};

String _priorityLabel(TaskPriority priority) => switch (priority) {
  TaskPriority.baja => 'Baja',
  TaskPriority.media => 'Media',
  TaskPriority.alta => 'Alta',
};

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    Future<void>.microtask(
      () => ref.read(tasksNotifierProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      unawaited(ref.read(tasksNotifierProvider.notifier).loadMore());
    }
  }

  Future<void> _sync() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(syncTasksUseCaseProvider)();
    await ref.read(tasksNotifierProvider.notifier).load();
    messenger.showSnackBar(
      const SnackBar(content: Text('Sincronización completada')),
    );
  }

  Future<bool> _confirmDelete(TaskEntity task) async {
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
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksNotifierProvider);
    return AppPageScaffold(
      title: 'Tareas',
      actions: [
        IconButton(
          tooltip: 'Sincronizar',
          onPressed: _sync,
          icon: const Icon(Icons.sync),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        tooltip: 'Nueva tarea',
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorView(
          message: 'Error: $error',
          onRetry: () => ref.read(tasksNotifierProvider.notifier).load(),
        ),
        data: (tasks) => Column(
          children: [
            const _FilterBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(tasksNotifierProvider.notifier).refresh(),
                child: tasks.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 160),
                          AppEmpty(message: 'Sin tareas'),
                        ],
                      )
                    : ListView.builder(
                        controller: _controller,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
                            key: ValueKey<String>(task.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(task),
                            onDismissed: (_) {
                              unawaited(
                                ref
                                    .read(tasksNotifierProvider.notifier)
                                    .deleteTask(task),
                              );
                            },
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text(
                                '${task.assignee} · vence '
                                '${task.dueDate.toLocal()}',
                              ),
                              trailing: TaskStatusChip(status: task.status),
                              onTap: () => context.push('/tasks/${task.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusFilterProvider);
    final priority = ref.watch(priorityFilterProvider);
    final notifier = ref.read(tasksNotifierProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<TaskStatus?>(
              initialValue: status,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Estado',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<TaskStatus?>(
                  value: null,
                  child: Text('Todos'),
                ),
                for (final value in TaskStatus.values)
                  DropdownMenuItem<TaskStatus?>(
                    value: value,
                    child: Text(_statusLabel(value)),
                  ),
              ],
              onChanged: (value) => notifier.setStatusFilter(value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<TaskPriority?>(
              initialValue: priority,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<TaskPriority?>(
                  value: null,
                  child: Text('Todas'),
                ),
                for (final value in TaskPriority.values)
                  DropdownMenuItem<TaskPriority?>(
                    value: value,
                    child: Text(_priorityLabel(value)),
                  ),
              ],
              onChanged: (value) => notifier.setPriorityFilter(value),
            ),
          ),
        ],
      ),
    );
  }
}
