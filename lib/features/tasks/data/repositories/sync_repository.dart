// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:taskflow_mobile_flutter/core/database/daos/task_dao.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/mappers/task_mapper.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';

class SyncResult {
  const SyncResult({required this.pushed, required this.pulled});

  final int pushed;
  final int pulled;
}

/// Sincroniza la base local Drift con la API remota.
///
/// Estrategia offline-first: se empujan primero los cambios locales pendientes
/// (crear/actualizar/eliminar) y luego se jalan los remotos aplicando
/// Last-Write-Wins por `updatedAt`.
class SyncRepository {
  SyncRepository({required TaskDao dao, required TaskRemoteDataSource remote})
    : _dao = dao,
      _remote = remote;

  final TaskDao _dao;
  final TaskRemoteDataSource _remote;

  Future<SyncResult> syncNow() async {
    final pushed = await _pushPending();
    final pulled = await _pullRemote();
    return SyncResult(pushed: pushed, pulled: pulled);
  }

  Future<int> _pushPending() async {
    final pending = await _dao.getPending();
    var pushed = 0;

    for (final row in pending) {
      try {
        if (row.deleted) {
          await _remote.deleteTask(row.id);
          await _dao.deleteById(row.id);
        } else {
          final updated = await _remote.updateTask(
            row.id,
            UpdateTaskRequest(
              title: row.title,
              description: row.description,
              status: TaskStatusX.fromWire(row.status),
              priority: TaskPriorityX.fromWire(row.priority),
              assignee: row.assignee,
              dueDate: row.dueDate,
            ),
          );
          await _dao.replace(dtoToRow(updated, synced: true));
        }
        pushed++;
      } on DioException catch (_) {
        // Fallo de red o 404 (recurso inexistente): se reintenta en el próximo sync.
      }
    }

    return pushed;
  }

  Future<int> _pullRemote() async {
    var pulled = 0;
    var page = 1;

    while (true) {
      final response = await _remote.getTasks(page: page);
      for (final dto in response.data) {
        final local = await _dao.getById(dto.id);
        final remoteIsNewer =
            local == null || !dto.updatedAt.isBefore(local.updatedAt);
        if (remoteIsNewer) {
          await _dao.upsert(dtoToRow(dto, synced: true));
          pulled++;
        }
      }
      if (page >= response.meta.lastPage) {
        break;
      }
      page++;
    }

    return pulled;
  }
}
