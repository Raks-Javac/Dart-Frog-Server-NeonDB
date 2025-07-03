import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_jwt_neon/models/response/response_model.dart';
import 'package:dart_frog_jwt_neon/models/task/task_model.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/repositories/task/task_repository.dart';
import 'package:dart_frog_jwt_neon/utils/logger.dart';
import 'package:dart_frog_jwt_neon/utils/utils.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _createUserTask(context),
    _ => Future.value(
        Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: failedResponse('Request not allowed'),
        ),
      ),
  };
}

Future<Response> _createUserTask(RequestContext context) async {
  if (await context.request.body() == "") {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: failedResponse('Invalid Request'),
    );
  }
  try {
    final user = context.read<User>();
    final taskRepository = context.read<TaskRepository>();
    final requestPayload = await context.request.json() as Map<String, dynamic>;

    final taskObject = Task(
      title: requestPayload['title'].toString(),
      description: requestPayload['description'].toString(),
      uid: const Uuid().v4(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final r = await taskRepository.create(user.uid ?? '', taskObject);
    AppLogger.info(r);

    return Response.json(
      body: ApiResponseModel(
        data: {
          'task_id': taskObject.toJson().remove('uid'),
        },
        isSuccessful: true,
        message: 'Task Created Successfully ',
      ),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.failedDependency,
      body: failedResponse(
        'Task Already Exist',
      ),
    );
  }
}
