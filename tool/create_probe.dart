import 'package:dio/dio.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

Future<void> main(List<String> args) async {
  final baseUrl = args.isNotEmpty
      ? args.first
      : 'https://taskflow-api-go.xprad.com';

  final request = CreateTaskRequest(
    title: 'probe auto',
    description: null,
    status: TaskStatus.pendiente,
    priority: TaskPriority.media,
    assignee: 'qa',
    dueDate: DateTime.now().add(const Duration(days: 1)),
  );

  final json = request.toJson();
  // ignore: avoid_print
  print('JSON: $json');

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  final response = await dio.post<dynamic>('/tasks', data: json);
  // ignore: avoid_print
  print('STATUS: ${response.statusCode}');
  // ignore: avoid_print
  print('BODY: ${response.data}');
}