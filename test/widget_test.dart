import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_mobile_flutter/app/app.dart';
import 'package:taskflow_mobile_flutter/app/providers.dart';
import 'package:taskflow_mobile_flutter/core/config/backend_store.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

import 'helpers/mocks.dart';

TaskEntity _task(String id) {
  return TaskEntity(
    id: id,
    title: 'Tarea $id',
    description: null,
    status: TaskStatus.pendiente,
    priority: TaskPriority.media,
    assignee: 'yonerloy',
    dueDate: DateTime.utc(2026, 1, 1),
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    registerTaskRepositoryFallbacks();
    prefs = await setupMockPreferences();
  });

  testWidgets('TasksPage renderiza la lista de tareas', (tester) async {
    final repo = MockTaskRepository();
    when(
      () => repo.getTasks(
        status: any(named: 'status'),
        priority: any(named: 'priority'),
        assignee: any(named: 'assignee'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => [_task('1')]);

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

    expect(find.text('Tareas'), findsWidgets);
    expect(find.text('Tarea 1'), findsOneWidget);
  });
}
