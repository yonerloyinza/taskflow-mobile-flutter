import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile_flutter/core/widgets/widgets.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/forms/task_form_inputs.dart';
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

class TaskFormPage extends ConsumerWidget {
  const TaskFormPage({super.key, this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = taskId != null;
    return AppPageScaffold(
      title: isEdit ? 'Editar tarea' : 'Nueva tarea',
      body: isEdit
          ? ref
                .watch(taskDetailProvider(taskId!))
                .when(
                  loading: () => const AppLoading(),
                  error: (error, _) => AppErrorView(message: 'Error: $error'),
                  data: (task) => _TaskForm(initial: task),
                )
          : const _TaskForm(initial: null),
    );
  }
}

class _TaskForm extends ConsumerStatefulWidget {
  const _TaskForm({required this.initial});

  final TaskEntity? initial;

  @override
  ConsumerState<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<_TaskForm> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _assignee;
  late TaskStatus _status;
  late TaskPriority _priority;
  late DateTime _dueDate;

  TaskTitleInput _titleInput = const TaskTitleInput.pure();
  TaskAssigneeInput _assigneeInput = const TaskAssigneeInput.pure();
  TaskDescriptionInput _descriptionInput = const TaskDescriptionInput.pure();
  bool _submitting = false;
  String? _errorMessage;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initial;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _assignee = TextEditingController(text: task?.assignee ?? 'yonerloy');
    _status = task?.status ?? TaskStatus.pendiente;
    _priority = task?.priority ?? TaskPriority.media;
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    if (task != null) {
      _titleInput = TaskTitleInput.dirty(task.title);
      _descriptionInput = TaskDescriptionInput.dirty(task.description ?? '');
      _assigneeInput = TaskAssigneeInput.dirty(task.assignee);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _assignee.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    final titleInput = TaskTitleInput.dirty(_title.text);
    final assigneeInput = TaskAssigneeInput.dirty(_assignee.text);
    final descriptionInput = TaskDescriptionInput.dirty(_description.text);
    final isValid = Formz.validate(<FormzInput<dynamic, dynamic>>[
      titleInput,
      assigneeInput,
      descriptionInput,
    ]);
    setState(() {
      _titleInput = titleInput;
      _assigneeInput = assigneeInput;
      _descriptionInput = descriptionInput;
      _errorMessage = null;
    });
    if (!isValid) {
      return;
    }

    setState(() => _submitting = true);
    final title = titleInput.value.trim();
    final assignee = assigneeInput.value.trim();
    final description = descriptionInput.value.isEmpty
        ? null
        : descriptionInput.value;
    final notifier = ref.read(tasksNotifierProvider.notifier);
    try {
      if (_isEdit) {
        await notifier.updateTaskFull(
          widget.initial!.id,
          title: title,
          description: description,
          status: _status,
          priority: _priority,
          assignee: assignee,
          dueDate: _dueDate,
        );
      } else {
        await notifier.createTaskFull(
          title: title,
          description: description,
          status: _status,
          priority: _priority,
          assignee: assignee,
          dueDate: _dueDate,
        );
      }
      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Error: $error');
        showAppSnackBar(context, 'Error: $error', error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        AppTextField(
          label: 'Título',
          controller: _title,
          errorText: _titleInput.isPure ? null : _titleInput.error?.message,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Descripción',
          controller: _description,
          maxLines: 3,
          errorText: _descriptionInput.isPure
              ? null
              : _descriptionInput.error?.message,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Asignado a',
          controller: _assignee,
          errorText: _assigneeInput.isPure
              ? null
              : _assigneeInput.error?.message,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<TaskStatus>(
          initialValue: _status,
          decoration: const InputDecoration(
            labelText: 'Estado',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final status in TaskStatus.values)
              DropdownMenuItem(
                value: status,
                child: Text(_statusLabel(status)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _status = value);
            }
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<TaskPriority>(
          initialValue: _priority,
          decoration: const InputDecoration(
            labelText: 'Prioridad',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final priority in TaskPriority.values)
              DropdownMenuItem(
                value: priority,
                child: Text(_priorityLabel(priority)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _priority = value);
            }
          },
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Fecha de vencimiento'),
            subtitle: Text(_dueDate.toLocal().toString().split(' ').first),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: _submitting ? 'Guardando...' : (_isEdit ? 'Guardar' : 'Crear'),
          onPressed: _submitting ? () {} : _submit,
        ),
      ],
    );
  }
}
