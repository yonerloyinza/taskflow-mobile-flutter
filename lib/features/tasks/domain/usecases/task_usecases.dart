import '../entities/task_entity.dart';
import '../entities/task_priority.dart';
import '../entities/task_status.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<TaskEntity>> call({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getTasks(
      status: status,
      priority: priority,
      assignee: assignee,
      page: page,
      limit: limit,
    );
  }
}

class WatchTasksUseCase {
  WatchTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<TaskEntity>> call() => _repository.watchTasks();
}

class GetTaskByIdUseCase {
  GetTaskByIdUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity> call(String id) => _repository.getTaskById(id);
}

class CreateTaskUseCase {
  CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity> call({
    required String title,
    String? description,
    TaskStatus status = TaskStatus.pendiente,
    TaskPriority priority = TaskPriority.media,
    required String assignee,
    required DateTime dueDate,
  }) {
    return _repository.createTask(
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee,
      dueDate: dueDate,
    );
  }
}

class UpdateTaskUseCase {
  UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity> call(
    String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignee,
    DateTime? dueDate,
  }) {
    return _repository.updateTask(
      id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee,
      dueDate: dueDate,
    );
  }
}

class DeleteTaskUseCase {
  DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String id) => _repository.deleteTask(id);
}

class SyncTasksUseCase {
  SyncTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call() => _repository.sync();
}
