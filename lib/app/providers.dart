import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/config/env.dart';
import '../core/database/app_database.dart';
import '../core/database/connection/connection.dart';
import '../core/database/daos/task_dao.dart';
import '../core/network/dio_client.dart';
import '../features/tasks/data/datasources/task_local_data_source.dart';
import '../features/tasks/data/datasources/task_remote_data_source.dart';
import '../features/tasks/data/repositories/sync_repository.dart';
import '../features/tasks/data/repositories/task_repository_impl.dart';
import '../features/tasks/domain/repositories/task_repository.dart';
import '../features/tasks/domain/usecases/task_usecases.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
    apiBaseUrl: Env.apiBaseUrl,
    environment: Env.environment,
  );
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return createDio(config);
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskRemoteDataSource(dio);
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openConnection());
  ref.onDispose(db.close);
  return db;
});

final taskDaoProvider = Provider<TaskDao>((ref) {
  return TaskDao(ref.watch(appDatabaseProvider));
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSource(ref.watch(taskDaoProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    dao: ref.watch(taskDaoProvider),
    remote: ref.watch(taskRemoteDataSourceProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    local: ref.watch(taskLocalDataSourceProvider),
    remote: ref.watch(taskRemoteDataSourceProvider),
    sync: ref.watch(syncRepositoryProvider),
  );
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final watchTasksUseCaseProvider = Provider<WatchTasksUseCase>((ref) {
  return WatchTasksUseCase(ref.watch(taskRepositoryProvider));
});

final getTaskByIdUseCaseProvider = Provider<GetTaskByIdUseCase>((ref) {
  return GetTaskByIdUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final syncTasksUseCaseProvider = Provider<SyncTasksUseCase>((ref) {
  return SyncTasksUseCase(ref.watch(taskRepositoryProvider));
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
