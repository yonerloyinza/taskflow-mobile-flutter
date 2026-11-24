import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

/// Smoke test contra un backend real.
///
/// Uso: `dart run tool/api_smoke.dart [baseUrl]`
/// Por defecto usa `API_BASE_URL` o `https://taskflow-api-go.xprad.com`.
Future<void> main(List<String> args) async {
  final baseUrl =
      args.isNotEmpty
          ? args.first
          : (Platform.environment['API_BASE_URL'] ??
                'https://taskflow-api-go.xprad.com');

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final api = TaskRemoteDataSource(dio);

  stdout.writeln('GET $baseUrl/tasks?page=1&limit=5');
  try {
    final page = await api.getTasks(page: 1, limit: 5);
    stdout.writeln(
      'OK  total=${page.meta.total} lastPage=${page.meta.lastPage} '
      'items=${page.data.length}',
    );
    for (final task in page.data.take(3)) {
      stdout.writeln(
        '  - ${task.id} | ${task.title} | ${task.status.wire} | '
        '${task.priority.wire} | ${task.assignee}',
      );
    }
  } catch (error) {
    stdout.writeln('ERROR $baseUrl -> $error');
    exitCode = 1;
  }
}