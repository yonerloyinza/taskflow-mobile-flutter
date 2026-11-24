import 'package:taskflow_mobile_flutter/core/database/app_database.dart';
import 'package:taskflow_mobile_flutter/core/database/daos/task_dao.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/mappers/task_mapper.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';

class TaskLocalDataSource {
  TaskLocalDataSource(this._dao);

  final TaskDao _dao;

  Stream<List<TaskDto>> watchTasks() {
    return _dao.watchAll().map((rows) => rows.map(rowToDto).toList());
  }

  Future<List<TaskDto>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(rowToDto).toList();
  }

  Future<TaskDto?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : rowToDto(row);
  }

  Future<void> saveSynced(TaskDto dto) {
    return _dao.upsert(dtoToRow(dto, synced: true));
  }

  Future<void> savePending(TaskDto dto) {
    return _dao.upsert(dtoToRow(dto, synced: false));
  }

  Future<void> markPendingDelete(TaskDto dto) {
    return _dao.upsert(dtoToRow(dto, synced: false, deleted: true));
  }

  Future<void> delete(String id) => _dao.deleteById(id);

  Future<List<TaskRow>> getPending() => _dao.getPending();

  Future<void> markSynced(String id) => _dao.markSynced(id);
}
