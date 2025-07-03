import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_jwt_neon/models/response/response_model.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/repositories/task/task_repository.dart';
import 'package:dart_frog_jwt_neon/utils/utils.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _getAllUserTask(context),
    _ => Future.value(
        Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: failedResponse('Request not allowed'),
        ),
      ),
  };
}

Future<Response> _getAllUserTask(RequestContext context) async {
  if (await context.request.body() == "") {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: failedResponse('Invalid Request'),
    );
  }
  try {
    final user = context.read<User>();
    final taskRepository = context.read<TaskRepository>();

    final allTask = await taskRepository.findAllTaskByUserUid(user.uid ?? '');

    if (allTask == null) {
      return Response.json(
        statusCode: HttpStatus.failedDependency,
        body: failedResponse(
          'Error fetching all task 2',
        ),
      );
    }

    return Response.json(
      body: ApiResponseModel(
        data: allTask,
        isSuccessful: true,
        message: 'All Tasks Fetched Successfully',
      ),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.failedDependency,
      body: failedResponse(
        'Error fetching all task $e',
      ),
    );
  }
}
