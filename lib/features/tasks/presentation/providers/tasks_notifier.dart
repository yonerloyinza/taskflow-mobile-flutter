import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_mobile_flutter/app/providers.dart';
import 'package:taskflow_mobile_flutter/core/config/backend.dart';
import 'package:taskflow_mobile_flutter/core/config/backend_store.dart';
import 'package:taskflow_mobile_flutter/core/constants/app_constants.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

final priorityFilterProvider = StateProvider<TaskPriority?>((ref) => null);

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TasksNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<BackendConfig>(backendProvider, (previous, next) {
      if (previous?.baseUrl != next.baseUrl) {
        unawaited(load());
      }
    });
  }

  final Ref _ref;
  int _page = 1;
  bool _hasMore = true;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _ref.read(getTasksUseCaseProvider)(
        status: _ref.read(statusFilterProvider),
        priority: _ref.read(priorityFilterProvider),
        page: 1,
      );
      _page = 1;
      _hasMore = result.length >= AppConstants.defaultPageSize;
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    try {
      final result = await _ref.read(getTasksUseCaseProvider)(
        status: _ref.read(statusFilterProvider),
        priority: _ref.read(priorityFilterProvider),
        page: 1,
      );
      _page = 1;
      _hasMore = result.length >= AppConstants.defaultPageSize;
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      // Refresh silencioso: si ya hay datos, se conservan; solo se reporta
      // el error cuando no hay nada que mostrar.
      if (current == null) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !_hasMore) {
      return;
    }
    try {
      final next = await _ref.read(getTasksUseCaseProvider)(
        status: _ref.read(statusFilterProvider),
        priority: _ref.read(priorityFilterProvider),
        page: _page + 1,
      );
      _page++;
      _hasMore = next.length >= AppConstants.defaultPageSize;
      state = AsyncValue.data(<TaskEntity>[...current, ...next]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void setStatusFilter(TaskStatus? status) {
    _ref.read(statusFilterProvider.notifier).state = status;
    unawaited(load());
  }

  void setPriorityFilter(TaskPriority? priority) {
    _ref.read(priorityFilterProvider.notifier).state = priority;
    unawaited(load());
  }

  Future<void> createTask({
    required String title,
    required String assignee,
  }) async {
    final created = await _ref.read(createTaskUseCaseProvider)(
      title: title,
      assignee: assignee,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    );
    final current = state.valueOrNull ?? <TaskEntity>[];
    state = AsyncValue.data(<TaskEntity>[created, ...current]);
  }

  /// Crea una tarea con todos los campos y la antepone al estado (optimista).
  Future<void> createTaskFull({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required String assignee,
    required DateTime dueDate,
  }) async {
    final created = await _ref.read(createTaskUseCaseProvider)(
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee,
      dueDate: dueDate,
    );
    final current = state.valueOrNull ?? <TaskEntity>[];
    state = AsyncValue.data(<TaskEntity>[created, ...current]);
  }

  /// Actualiza una tarea y refleja el cambio en el estado (optimista).
  Future<void> updateTaskFull(
    String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    DateTime? dueDate,
  }) async {
    final updated = await _ref.read(updateTaskUseCaseProvider)(
      id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee,
      dueDate: dueDate,
    );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(<TaskEntity>[
        for (final item in current) item.id == id ? updated : item,
      ]);
    }
  }

  Future<void> toggleStatus(TaskEntity task) async {
    final nextStatus = task.status == TaskStatus.hexa
        ? TaskStatus.pendiente
        : TaskStatus.hexa;
    final updated = task.copyWith(
      status: nextStatus,
      updatedAt: DateTime.now(),
    );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(<TaskEntity>[
        for (final item in current) item.id == task.id ? updated : item,
      ]);
    }
    await _ref.read(updateTaskUseCaseProvider)(task.id, status: nextStatus);
  }

  Future<void> deleteTask(TaskEntity task) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.where((item) => item.id != task.id).toList(),
      );
    }
    await _ref.read(deleteTaskUseCaseProvider)(task.id);
  }
}
