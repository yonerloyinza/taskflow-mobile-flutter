import 'package:mocktail/mocktail.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void registerTaskRepositoryFallbacks() {
  registerFallbackValue(
    CreateTaskRequest(
      title: 'fallback',
      assignee: 'fallback',
      dueDate: DateTime.utc(2020),
    ),
  );
  registerFallbackValue(const UpdateTaskRequest());
}
