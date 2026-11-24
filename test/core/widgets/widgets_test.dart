import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/core/widgets/widgets.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('AppLoading muestra indicador', (tester) async {
    await tester.pumpWidget(_wrap(const AppLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppEmpty muestra mensaje e icono', (tester) async {
    await tester.pumpWidget(_wrap(const AppEmpty(message: 'Sin tareas')));
    expect(find.text('Sin tareas'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('AppErrorView muestra mensaje y reintento', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(AppErrorView(message: 'Fallo', onRetry: () => retried = true)),
    );
    expect(find.text('Fallo'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(retried, isTrue);
  });

  testWidgets('TaskStatusChip muestra la etiqueta', (tester) async {
    await tester.pumpWidget(
      _wrap(const TaskStatusChip(status: TaskStatus.enCurso)),
    );
    expect(find.text('En curso'), findsOneWidget);
  });

  testWidgets('TaskPriorityChip muestra la etiqueta', (tester) async {
    await tester.pumpWidget(
      _wrap(const TaskPriorityChip(priority: TaskPriority.alta)),
    );
    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('AppButton dispara onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      _wrap(AppButton(label: 'Crear', onPressed: () => pressed = true)),
    );
    await tester.tap(find.text('Crear'));
    expect(pressed, isTrue);
  });
}
