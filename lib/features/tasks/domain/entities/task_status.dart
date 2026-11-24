enum TaskStatus { pendiente, enCurso, hexa }

extension TaskStatusX on TaskStatus {
  String get wire => switch (this) {
    TaskStatus.pendiente => 'pendiente',
    TaskStatus.enCurso => 'en_curso',
    TaskStatus.hexa => 'hexa',
  };

  static TaskStatus fromWire(String value) => switch (value) {
    'pendiente' => TaskStatus.pendiente,
    'en_curso' => TaskStatus.enCurso,
    'hexa' => TaskStatus.hexa,
    _ => throw ArgumentError.value(value, 'wire', 'TaskStatus desconocido'),
  };

  static TaskStatus? tryFromWire(String? value) => switch (value) {
    'pendiente' => TaskStatus.pendiente,
    'en_curso' => TaskStatus.enCurso,
    'hexa' => TaskStatus.hexa,
    _ => null,
  };
}
