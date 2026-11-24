import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow_mobile_flutter/core/database/app_database.dart';
import 'package:taskflow_mobile_flutter/core/database/daos/task_dao.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/repositories/sync_repository.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

class _MockRemote extends Mock implements TaskRemoteDataSource {}

TaskDto _dto(
  String id, {
  String title = 'tarea',
  TaskStatus status = TaskStatus.pendiente,
  TaskPriority priority = TaskPriority.media,
  DateTime? updatedAt,
}) {
  return TaskDto(
    id: id,
    title: title,
    description: null,
    status: status,
    priority: priority,
    assignee: 'yonerloy',
    dueDate: DateTime.utc(2026, 1, 1),
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: updatedAt ?? DateTime.utc(2025, 1, 1),
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
  late TaskLocalDataSource local;
  late _MockRemote remote;
  late TaskRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CreateTaskRequest(
        title: 'fallback',
        assignee: 'fallback',
        dueDate: DateTime.utc(2020),
      ),
    );
    registerFallbackValue(const UpdateTaskRequest());
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = TaskDao(db);
    local = TaskLocalDataSource(dao);
    remote = _MockRemote();
    repository = TaskRepositoryImpl(
      local: local,
      remote: remote,
      sync: SyncRepository(dao: dao, remote: remote),
    );
  });

  tearDown(() async => db.close());

  test('getTasks obtiene del remoto y cachea en local', () async {
    when(
      () => remote.getTasks(
        status: any(named: 'status'),
        priority: any(named: 'priority'),
        assignee: any(named: 'assignee'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => _page([_dto('1'), _dto('2')]));

    final tasks = await repository.getTasks();

    expect(tasks, hasLength(2));
    expect(await dao.getAll(), hasLength(2));
  });

  test('getTaskById cae al remoto si no está en local', () async {
    when(() => remote.getTaskById(any())).thenAnswer((_) async => _dto('9'));

    final task = await repository.getTaskById('9');

    expect(task.id, '9');
    expect(await dao.getById('9'), isNotNull);
  });

  test('createTask crea en remoto y cachea', () async {
    when(() => remote.createTask(any()))
        .thenAnswer((_) async => _dto('1', title: 'creada'));

    final task = await repository.createTask(
      title: 'creada',
      status: TaskStatus.pendiente,
      priority: TaskPriority.media,
      assignee: 'yonerloy',
      dueDate: DateTime.utc(2026, 1, 1),
    );

    expect(task.title, 'creada');
    expect(await dao.getById('1'), isNotNull);
  });

  test(
    'updateTask optimista: actualiza y marca sincronizado al responder ok',
    () async {
      await local.saveSynced(_dto('1', title: 'original'));
      when(() => remote.updateTask(any(), any())).thenAnswer(
        (_) async => _dto(
          '1',
          title: 'actualizada',
          updatedAt: DateTime.utc(2025, 6, 1),
        ),
      );

      final task = await repository.updateTask('1', title: 'actualizada');

      expect(task.title, 'actualizada');
      expect(await dao.getPending(), isEmpty);
    },
  );

  test('updateTask sin red: conserva cambio pendiente', () async {
    await local.saveSynced(_dto('1', title: 'original'));
    when(() => remote.updateTask(any(), any())).thenThrow(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/tasks/1'),
        reason: 'offline',
      ),
    );

    final task = await repository.updateTask('1', title: 'cambio local');

    expect(task.title, 'cambio local');
    expect(await dao.getPending(), hasLength(1));
  });

  test('deleteTask elimina en local tras borrado remoto', () async {
    await local.saveSynced(_dto('1'));
    when(() => remote.deleteTask(any())).thenAnswer((_) async {});

    await repository.deleteTask('1');

    expect(await dao.getById('1'), isNull);
  });
}
