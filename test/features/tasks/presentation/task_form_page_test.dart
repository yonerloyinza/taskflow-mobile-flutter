import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_mobile_flutter/app/app.dart';
import 'package:taskflow_mobile_flutter/app/providers.dart';
import 'package:taskflow_mobile_flutter/core/config/backend_store.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/repositories/task_repository.dart';

import '../../../helpers/mocks.dart';

class _FakeRepo implements TaskRepository {
  TaskEntity? created;

  @override
  Stream<List<TaskEntity>> watchTasks() =>
      const Stream<List<TaskEntity>>.empty();

  @override
  Future<List<TaskEntity>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    int page = 1,
    int limit = 10,
  }) async => <TaskEntity>[];

  @override
  Future<TaskEntity> getTaskById(String id) async {
    throw StateError('nope');
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
    final task = TaskEntity(
      id: 'nuevo',
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee,
      dueDate: dueDate,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
    );
    created = task;
    return task;
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
    throw StateError('nope');
  }

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<void> sync() async {}
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    prefs = await setupMockPreferences();
  });

  testWidgets('crear envía assignee no vacío y muestra la tarea', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          taskRepositoryProvider.overrideWithValue(repo),
        ],
        child: const TaskflowApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Mi tarea');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Crear'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(repo.created, isNotNull);
    expect(repo.created!.assignee, 'yonerloy');
    expect(repo.created!.title, 'Mi tarea');
    expect(find.text('Mi tarea'), findsOneWidget);
  });
}
