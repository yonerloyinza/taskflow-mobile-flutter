// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/mappers/task_mapper.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/repositories/sync_repository.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskLocalDataSource local,
    required TaskRemoteDataSource remote,
    required SyncRepository sync,
  }) : _local = local,
       _remote = remote,
       _sync = sync;

  final TaskLocalDataSource _local;
  final TaskRemoteDataSource _remote;
  final SyncRepository _sync;

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return _local.watchTasks().map(
      (dtos) => dtos.map(dtoToEntity).toList(growable: false),
    );
  }

  @override
  Future<List<TaskEntity>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _remote.getTasks(
      status: status?.wire,
      priority: priority?.wire,
      assignee: assignee,
      page: page,
      limit: limit,
    );
    for (final dto in response.data) {
      await _local.saveSynced(dto);
    }
    return response.data.map(dtoToEntity).toList(growable: false);
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    final local = await _local.getById(id);
    if (local != null) {
      return dtoToEntity(local);
    }
    final dto = await _remote.getTaskById(id);
    await _local.saveSynced(dto);
    return dtoToEntity(dto);
  }

  @override
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required String assignee,
    required DateTime dueDate,
  }) async {
    final dto = await _remote.createTask(
      CreateTaskRequest(
        title: title,
        description: description,
        status: status,
        priority: priority,
        assignee: assignee,
        dueDate: dueDate,
      ),
    );
    await _local.saveSynced(dto);
    return dtoToEntity(dto);
  }

  @override
  Future<TaskEntity> updateTask(
    String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    DateTime? dueDate,
  }) async {
    final current = await _local.getById(id);
    final now = DateTime.now();
    final optimistic = TaskDto(
      id: id,
      title: title ?? current?.title ?? '',
      description: description ?? current?.description,
      status: status ?? current?.status ?? TaskStatus.pendiente,
      priority: priority ?? current?.priority ?? TaskPriority.media,
      assignee: assignee ?? current?.assignee ?? '',
      dueDate: dueDate ?? current?.dueDate ?? now,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    // Optimistic: la UI ve el cambio local de inmediato.
    await _local.savePending(optimistic);

    try {
      final updated = await _remote.updateTask(
        id,
        UpdateTaskRequest(
          title: title,
          description: description,
          status: status,
          priority: priority,
          assignee: assignee,
          dueDate: dueDate,
        ),
      );
      await _local.saveSynced(updated);
      return dtoToEntity(updated);
    } on DioException {
      // Sin red: el cambio queda pendiente y se sincroniza después.
      return dtoToEntity(optimistic);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final current = await _local.getById(id);
    if (current != null) {
      await _local.markPendingDelete(current);
    }
    try {
      await _remote.deleteTask(id);
      await _local.delete(id);
    } on DioException {
      // Sin red: se conserva el tombstone para sincronizar luego.
    }
  }

  @override
  Future<void> sync() async {
    await _sync.syncNow();
  }
}
