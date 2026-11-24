import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/features/tasks/data/models/task_models.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_priority.dart';
import 'package:taskflow_mobile_flutter/features/tasks/domain/entities/task_status.dart';

void main() {
  group('TaskStatus wire', () {
    test('serializa y deserializa valores del contrato', () {
      expect(TaskStatus.pendiente.wire, 'pendiente');
      expect(TaskStatus.enCurso.wire, 'en_curso');
      expect(TaskStatus.hexa.wire, 'hexa');
      expect(TaskStatusX.fromWire('en_curso'), TaskStatus.enCurso);
      expect(TaskStatusX.tryFromWire('desconocido'), isNull);
    });
  });

  group('TaskPriority wire', () {
    test('serializa y deserializa valores del contrato', () {
      expect(TaskPriority.baja.wire, 'baja');
      expect(TaskPriority.media.wire, 'media');
      expect(TaskPriority.alta.wire, 'alta');
      expect(TaskPriorityX.fromWire('alta'), TaskPriority.alta);
    });
  });

  group('TaskDto', () {
    test('round-trip json respeta el contrato', () {
      final json = <String, dynamic>{
        'id': 'abc-123',
        'title': 'Mi tarea',
        'description': 'descripcion',
        'status': 'en_curso',
        'priority': 'alta',
        'assignee': 'yonerloy',
        'dueDate': '2026-01-01T00:00:00.000Z',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-06-01T00:00:00.000Z',
      };

      final task = TaskDto.fromJson(json);

      expect(task.id, 'abc-123');
      expect(task.status, TaskStatus.enCurso);
      expect(task.priority, TaskPriority.alta);
      expect(task.toJson()['status'], 'en_curso');
      expect(task.toJson()['priority'], 'alta');
      expect(TaskDto.fromJson(task.toJson()), task);
    });
  });

  group('CreateTaskRequest', () {
    test('aplica defaults status=pendiente y priority=media', () {
      final req = CreateTaskRequest(
        title: 'nueva',
        assignee: 'yonerloy',
        dueDate: DateTime.utc(2026, 1, 1),
      );

      final json = req.toJson();
      expect(json['status'], 'pendiente');
      expect(json['priority'], 'media');
      expect(json['title'], 'nueva');
      expect(json['assignee'], 'yonerloy');
    });
  });

  group('PaginatedTasksResponse', () {
    test('parsea data y meta', () {
      final json = <String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{
            'id': '1',
            'title': 'a',
            'status': 'pendiente',
            'priority': 'media',
            'assignee': 'yo',
            'dueDate': '2026-01-01T00:00:00.000Z',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-01T00:00:00.000Z',
          },
        ],
        'meta': <String, dynamic>{
          'total': 1,
          'page': 1,
          'limit': 10,
          'lastPage': 1,
        },
      };

      final res = PaginatedTasksResponse.fromJson(json);

      expect(res.data, hasLength(1));
      expect(res.data.single.status, TaskStatus.pendiente);
      expect(res.meta.total, 1);
      expect(res.meta.page, 1);
      expect(res.meta.limit, 10);
      expect(res.meta.lastPage, 1);
    });
  });

  group('ErrorResponse', () {
    test('message acepta string y lista', () {
      final asString = ErrorResponse.fromJson(<String, dynamic>{
        'statusCode': 400,
        'error': 'Bad Request',
        'message': 'campo invalido',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'path': '/tasks',
      });
      expect(asString.message, 'campo invalido');

      final asList = ErrorResponse.fromJson(<String, dynamic>{
        'statusCode': 400,
        'error': 'Bad Request',
        'message': <dynamic>['a', 'b'],
        'timestamp': '2026-01-01T00:00:00.000Z',
        'path': '/tasks',
      });
      expect(asList.message, <dynamic>['a', 'b']);
    });
  });
}
