import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/core/database/app_database.dart';
import 'package:taskflow_mobile_flutter/core/database/daos/task_dao.dart';

TaskRow _row(
  String id, {
  bool synced = false,
  bool deleted = false,
  DateTime? updatedAt,
}) {
  final now = updatedAt ?? DateTime.utc(2025, 1, 1);
  return TaskRow(
    id: id,
    title: 'tarea-$id',
    description: null,
    status: 'pendiente',
    priority: 'media',
    assignee: 'yonerloy',
    dueDate: now,
    createdAt: now,
    updatedAt: now,
    synced: synced,
    deleted: deleted,
  );
}

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = TaskDao(db);
  });

  tearDown(() async => db.close());

  test('insert y getById', () async {
    await dao.insert(_row('1'));
    final row = await dao.getById('1');
    expect(row?.id, '1');
    expect(row?.title, 'tarea-1');
  });

  test('upsert actualiza sin duplicar', () async {
    await dao.insert(_row('1'));
    await dao.upsert(_row('1', synced: true));
    final all = await dao.getAll();
    expect(all, hasLength(1));
    expect((await dao.getById('1'))?.synced, isTrue);
  });

  test('watchAll refleja el estado actual', () async {
    expect(await dao.watchAll().first, isEmpty);
    await dao.insert(_row('1'));
    expect(await dao.watchAll().first, hasLength(1));
  });

  test('getPending y markSynced', () async {
    await dao.insert(_row('1', synced: false));
    await dao.insert(_row('2', synced: true));

    expect(await dao.getPending(), hasLength(1));

    await dao.markSynced('1');
    expect(await dao.getPending(), isEmpty);
  });

  test('deleteById elimina y devuelve filas afectadas', () async {
    await dao.insert(_row('1'));
    final affected = await dao.deleteById('1');
    expect(affected, 1);
    expect(await dao.getById('1'), isNull);
  });
}
