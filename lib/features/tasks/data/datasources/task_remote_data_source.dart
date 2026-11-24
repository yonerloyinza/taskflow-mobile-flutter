import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/task_models.dart';

part 'task_remote_data_source.g.dart';

@RestApi()
abstract class TaskRemoteDataSource {
  factory TaskRemoteDataSource(Dio dio, {String baseUrl}) =
      _TaskRemoteDataSource;

  @GET('/tasks')
  Future<PaginatedTasksResponse> getTasks({
    @Query('status') String? status,
    @Query('priority') String? priority,
    @Query('assignee') String? assignee,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/tasks/{id}')
  Future<TaskDto> getTaskById(@Path('id') String id);

  @POST('/tasks')
  Future<TaskDto> createTask(@Body() CreateTaskRequest request);

  @PATCH('/tasks/{id}')
  Future<TaskDto> updateTask(
    @Path('id') String id,
    @Body() UpdateTaskRequest request,
  );

  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);
}
