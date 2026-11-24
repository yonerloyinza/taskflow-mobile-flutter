import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/presentation/settings_page.dart';
import '../features/tasks/presentation/pages/task_detail_page.dart';
import '../features/tasks/presentation/pages/task_form_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';
import 'app_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/tasks',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksPage(),
              ),
              GoRoute(
                path: '/tasks/new',
                builder: (context, state) => const TaskFormPage(),
              ),
              GoRoute(
                path: '/tasks/:id',
                builder: (context, state) =>
                    TaskDetailPage(taskId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: '/tasks/:id/edit',
                builder: (context, state) =>
                    TaskFormPage(taskId: state.pathParameters['id']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
