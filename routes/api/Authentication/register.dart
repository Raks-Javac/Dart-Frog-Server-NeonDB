import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_jwt_neon/models/response/response_model.dart';
import 'package:dart_frog_jwt_neon/repositories/user/user_repository.dart';
import 'package:dart_frog_jwt_neon/utils/utils.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _registerUser(context),
    _ => Future.value(
        Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: failedResponse('Request not allowed'),
        ),
      ),
  };
}

Future<Response> _registerUser(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  if (username == null || password == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final authenticator = context.read<UserRepository>();

  final user = authenticator.findByUsernameAndPassword(
    username: username,
    password: password,
  );

  if (user == null) {
    return Response(statusCode: HttpStatus.unauthorized);
  } else {
    return Response.json(
      body: ApiResponseModel(
        data: {
          'token': authenticator.generateToken(user),
        },
        isSuccessful: true,
        message: 'User logged in successfully',
      ),
    );
  }
}
