import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/features/tasks/presentation/forms/task_form_inputs.dart';

void main() {
  group('TaskTitleInput', () {
    test('vacío', () {
      expect(const TaskTitleInput.dirty('').error, TaskTitleError.empty);
    });
    test('demasiado corto', () {
      expect(const TaskTitleInput.dirty('ab').error, TaskTitleError.tooShort);
    });
    test('demasiado largo', () {
      expect(TaskTitleInput.dirty('a' * 101).error, TaskTitleError.tooLong);
    });
    test('válido', () {
      expect(const TaskTitleInput.dirty('abc').error, isNull);
    });
  });

  test('TaskAssigneeInput vacío', () {
    expect(const TaskAssigneeInput.dirty('').error, TaskAssigneeError.empty);
  });

  test('TaskDescriptionInput demasiado largo', () {
    expect(
      TaskDescriptionInput.dirty('a' * 501).error,
      TaskDescriptionError.tooLong,
    );
  });
}
