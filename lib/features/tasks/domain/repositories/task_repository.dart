import '../entities/task_entity.dart';
import '../entities/task_priority.dart';
import '../entities/task_status.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchTasks();

  Future<List<TaskEntity>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    int page = 1,
    int limit = 10,
  });

  Future<TaskEntity> getTaskById(String id);

  Future<TaskEntity> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required String assignee,
    required DateTime dueDate,
  });

  Future<TaskEntity> updateTask(
    String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    DateTime? dueDate,
  });

  Future<void> deleteTask(String id);

  Future<void> sync();
}
