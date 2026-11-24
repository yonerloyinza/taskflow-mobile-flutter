import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_mobile_flutter/app/providers.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_entity.dart';

import 'tasks_notifier.dart';

final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskEntity>>>((ref) {
      return TasksNotifier(ref);
    });

final taskDetailProvider = FutureProvider.family<TaskEntity, String>((ref, id) {
  return ref.watch(getTaskByIdUseCaseProvider)(id);
});
