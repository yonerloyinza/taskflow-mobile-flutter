import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<TaskRow>> watchAll() {
    return (select(
      tasks,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  Future<List<TaskRow>> getAll() => select(tasks).get();

  Future<TaskRow?> getById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(TaskRow row) {
    return into(tasks).insertOnConflictUpdate(row);
  }

  Future<int> insert(TaskRow row) => into(tasks).insert(row);

  Future<bool> replace(TaskRow row) => update(tasks).replace(row);

  Future<int> deleteById(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<List<TaskRow>> getPending() {
    return (select(tasks)..where((t) => t.synced.equals(false))).get();
  }

  Future<int> markSynced(String id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(synced: Value(true)),
    );
  }

  Future<int> markUnsynced(String id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(synced: Value(false)),
    );
  }
}
