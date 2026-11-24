import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/app/app.dart';

void main() {
  testWidgets('TaskflowApp renderiza la pantalla de tareas', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaskflowApp()));
    await tester.pumpAndSettle();

    expect(find.text('Tareas'), findsOneWidget);
    expect(find.text('Lista de tareas'), findsOneWidget);
  });
}
