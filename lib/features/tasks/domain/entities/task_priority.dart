enum TaskPriority { baja, media, alta }

extension TaskPriorityX on TaskPriority {
  String get wire => switch (this) {
    TaskPriority.baja => 'baja',
    TaskPriority.media => 'media',
    TaskPriority.alta => 'alta',
  };

  static TaskPriority fromWire(String value) => switch (value) {
    'baja' => TaskPriority.baja,
    'media' => TaskPriority.media,
    'alta' => TaskPriority.alta,
    _ => throw ArgumentError.value(value, 'wire', 'TaskPriority desconocido'),
  };

  static TaskPriority? tryFromWire(String? value) => switch (value) {
    'baja' => TaskPriority.baja,
    'media' => TaskPriority.media,
    'alta' => TaskPriority.alta,
    _ => null,
  };
}
