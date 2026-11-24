import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile_flutter/core/widgets/widgets.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/providers/tasks_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksNotifierProvider);
    return AppPageScaffold(
      title: 'Tareas',
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        tooltip: 'Nueva tarea',
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorView(
          message: 'Error: $error',
          onRetry: () => ref.read(tasksNotifierProvider.notifier).load(),
        ),
        data: (tasks) => RefreshIndicator(
          onRefresh: () => ref.read(tasksNotifierProvider.notifier).refresh(),
          child: tasks.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 200),
                    AppEmpty(message: 'Sin tareas'),
                  ],
                )
              : ListView.builder(
                  controller: _controller,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        '${task.assignee} · vence '
                        '${task.dueDate.toLocal()}',
                      ),
                      trailing: TaskStatusChip(status: task.status),
                      onTap: () => context.push('/tasks/${task.id}'),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _CreateTaskDialog(),
    );
    if (title == null || title.isEmpty) {
      return;
    }
    await ref
        .read(tasksNotifierProvider.notifier)
        .createTask(title: title, assignee: 'yonerloy');
  }
}

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog();

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva tarea'),
      content: AppTextField(
        label: 'Título',
        controller: _controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Crear')),
      ],
    );
  }
}
