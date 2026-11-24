import 'package:formz/formz.dart';

enum TaskTitleError { empty, tooShort, tooLong }

class TaskTitleInput extends FormzInput<String, TaskTitleError> {
  const TaskTitleInput.pure() : super.pure('');
  const TaskTitleInput.dirty(super.value) : super.dirty();

  @override
  TaskTitleError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return TaskTitleError.empty;
    }
    if (trimmed.length < 3) {
      return TaskTitleError.tooShort;
    }
    if (value.length > 100) {
      return TaskTitleError.tooLong;
    }
    return null;
  }
}

extension TaskTitleErrorX on TaskTitleError {
  String get message => switch (this) {
    TaskTitleError.empty => 'El título es obligatorio.',
    TaskTitleError.tooShort => 'El título debe tener al menos 3 caracteres.',
    TaskTitleError.tooLong => 'El título no puede superar 100 caracteres.',
  };
}

enum TaskAssigneeError { empty, tooLong }

class TaskAssigneeInput extends FormzInput<String, TaskAssigneeError> {
  const TaskAssigneeInput.pure() : super.pure('');
  const TaskAssigneeInput.dirty(super.value) : super.dirty();

  @override
  TaskAssigneeError? validator(String value) {
    if (value.trim().isEmpty) {
      return TaskAssigneeError.empty;
    }
    if (value.length > 100) {
      return TaskAssigneeError.tooLong;
    }
    return null;
  }
}

extension TaskAssigneeErrorX on TaskAssigneeError {
  String get message => switch (this) {
    TaskAssigneeError.empty => 'El asignado es obligatorio.',
    TaskAssigneeError.tooLong => 'El asignado no puede superar 100 caracteres.',
  };
}

enum TaskDescriptionError { tooLong }

class TaskDescriptionInput extends FormzInput<String, TaskDescriptionError> {
  const TaskDescriptionInput.pure() : super.pure('');
  const TaskDescriptionInput.dirty(super.value) : super.dirty();

  @override
  TaskDescriptionError? validator(String value) =>
      value.length > 500 ? TaskDescriptionError.tooLong : null;
}

extension TaskDescriptionErrorX on TaskDescriptionError {
  String get message => 'La descripción no puede superar 500 caracteres.';
}
