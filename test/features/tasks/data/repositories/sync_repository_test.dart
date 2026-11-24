import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow_mobile_flutter/core/database/app_database.dart';
import 'package:taskflow_mobile_flutter/core/database/daos/task_dao.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/mappers/task_mapper.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/repositories/sync_repository.dart';

class _MockRemote extends Mock implements TaskRemoteDataSource {}

TaskDto _dto(
  String id, {
  required DateTime updatedAt,
  String title = 'remota',
}) {
  return TaskDto(
    id: id,
    title: title,
    status: TaskStatus.enCurso,
    priority: TaskPriority.alta,
    assignee: 'yonerloy',
    dueDate: DateTime.utc(2026, 1, 1),
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: updatedAt,
  );
}

PaginatedTasksResponse _page(List<TaskDto> data) {
  return PaginatedTasksResponse(
    data: data,
    meta: PageMeta(total: data.length, page: 1, limit: 10, lastPage: 1),
  );
}

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUpAll(() {
    registerFallbackValue(const UpdateTaskRequest());
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = TaskDao(db);
  });

  tearDown(() async => db.close());

  test('syncNow empuja pendientes y las marca sincronizadas', () async {
    final remote = _MockRemote();
    final base = DateTime.utc(2025, 1, 1);
    await dao.upsert(dtoToRow(_dto('1', updatedAt: base), synced: false));

    when(() => remote.updateTask(any(), any())).thenAnswer(
      (_) async => _dto('1', updatedAt: base.add(const Duration(hours: 1))),
    );
    when(() => remote.getTasks(page: any(named: 'page')))
        .thenAnswer((_) async => _page([_dto('1', updatedAt: base)]));

    final repo = SyncRepository(dao: dao, remote: remote);
    final result = await repo.syncNow();

    expect(result.pushed, 1);
    expect(await dao.getPending(), isEmpty);
    verify(() => remote.updateTask(any(), any())).called(1);
  });

  test('syncNow jala remoto aplicando Last-Write-Wins', () async {
    final remote = _MockRemote();
    final base = DateTime.utc(2025, 1, 1);
    final newer = base.add(const Duration(days: 1));
    await dao.upsert(dtoToRow(_dto('1', updatedAt: base), synced: true));

    when(() => remote.getTasks(page: any(named: 'page')))
        .thenAnswer((_) async => _page([_dto('1', updatedAt: newer)]));

    final repo = SyncRepository(dao: dao, remote: remote);
    final result = await repo.syncNow();

    expect(result.pulled, 1);
    final row = await dao.getById('1');
    expect(row?.updatedAt.millisecondsSinceEpoch, newer.millisecondsSinceEpoch);
  });

  test('syncNow conserva el local si es más reciente que el remoto', () async {
    final remote = _MockRemote();
    final base = DateTime.utc(2025, 1, 1);
    final localNewer = base.add(const Duration(days: 2));
    await dao.upsert(dtoToRow(_dto('1', updatedAt: localNewer), synced: true));

    when(() => remote.getTasks(page: any(named: 'page')))
        .thenAnswer((_) async => _page([_dto('1', updatedAt: base)]));

    final repo = SyncRepository(dao: dao, remote: remote);
    final result = await repo.syncNow();

    expect(result.pulled, 0);
    final row = await dao.getById('1');
    expect(
      row?.updatedAt.millisecondsSinceEpoch,
      localNewer.millisecondsSinceEpoch,
    );
  });
}
