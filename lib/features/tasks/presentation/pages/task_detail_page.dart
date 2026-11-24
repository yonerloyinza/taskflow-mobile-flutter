import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de tarea')),
      body: Center(child: Text('Tarea $taskId')),
    );
  }
}
