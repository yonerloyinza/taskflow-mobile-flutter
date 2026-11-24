import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/app/providers.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/providers/tasks_providers.dart';

TaskEntity _task(String id, {TaskStatus status = TaskStatus.pendiente}) {
  return TaskEntity(
    id: id,
    title: 'tarea-$id',
    description: null,
    status: status,
    priority: TaskPriority.media,
    assignee: 'yonerloy',
    dueDate: DateTime.utc(2026, 1, 1),
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({List<TaskEntity>? initial, this.error})
    : _tasks = initial ?? <TaskEntity>[];

  List<TaskEntity> _tasks;
  final Object? error;
  int updateCount = 0;
  final List<String> deleted = <String>[];

  @override
  Stream<List<TaskEntity>> watchTasks() =>
      Stream<List<TaskEntity>>.value(List<TaskEntity>.of(_tasks));

  @override
  Future<List<TaskEntity>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    int page = 1,
    int limit = 10,
  }) async {
    if (error != null) {
      throw error!;
    }
    return List<TaskEntity>.of(_tasks);
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    return _tasks.firstWhere((task) => task.id == id);
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
    final created = _task('nueva');
    _tasks = <TaskEntity>[created, ..._tasks];
    return created;
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
    updateCount++;
    final index = _tasks.indexWhere((task) => task.id == id);
    final updated = _tasks[index].copyWith(
      status: status ?? _tasks[index].status,
    );
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    deleted.add(id);
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<void> sync() async {}
}

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer(_FakeTaskRepository repo) {
    final c = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('load expone AsyncValue.data', () async {
    final repo = _FakeTaskRepository(
      initial: <TaskEntity>[_task('1'), _task('2')],
    );
    container = buildContainer(repo);

    await container.read(tasksNotifierProvider.notifier).load();

    final state = container.read(tasksNotifierProvider);
    expect(state.hasValue, isTrue);
    expect(state.valueOrNull, hasLength(2));
  });

  test('load error expone AsyncValue.error', () async {
    final repo = _FakeTaskRepository(error: Exception('boom'));
    container = buildContainer(repo);

    await container.read(tasksNotifierProvider.notifier).load();

    expect(container.read(tasksNotifierProvider).hasError, isTrue);
  });

  test('createTask antepone la tarea creada', () async {
    final repo = _FakeTaskRepository(initial: <TaskEntity>[_task('1')]);
    container = buildContainer(repo);

    final notifier = container.read(tasksNotifierProvider.notifier);
    await notifier.load();
    await notifier.createTask(title: 'nueva', assignee: 'yonerloy');

    final tasks = container.read(tasksNotifierProvider).valueOrNull;
    expect(tasks?.first.id, 'nueva');
    expect(tasks, hasLength(2));
  });

  test('toggleStatus actualiza el estado y persiste', () async {
    final repo = _FakeTaskRepository(initial: <TaskEntity>[_task('1')]);
    container = buildContainer(repo);

    final notifier = container.read(tasksNotifierProvider.notifier);
    await notifier.load();
    await notifier.toggleStatus(_task('1'));

    final tasks = container.read(tasksNotifierProvider).valueOrNull;
    expect(tasks?.single.status, TaskStatus.hexa);
    expect(repo.updateCount, 1);
  });

  test('deleteTask quita la tarea de la lista', () async {
    final repo = _FakeTaskRepository(
      initial: <TaskEntity>[_task('1'), _task('2')],
    );
    container = buildContainer(repo);

    final notifier = container.read(tasksNotifierProvider.notifier);
    await notifier.load();
    await notifier.deleteTask(_task('1'));

    final tasks = container.read(tasksNotifierProvider).valueOrNull;
    expect(tasks, hasLength(1));
    expect(tasks?.single.id, '2');
    expect(repo.deleted, <String>['1']);
  });
}
