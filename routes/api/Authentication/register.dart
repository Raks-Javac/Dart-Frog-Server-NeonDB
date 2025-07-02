import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/repositories/user/user_repository.dart';
import 'package:dart_frog_jwt_neon/utils/settings.dart';
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
  final username = body['username'];
  final password = body['password'];

  if (username == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: failedResponse('Pass a valid username'),
    );
  }

  if (password == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: failedResponse('User log in failed'),
    );
  }

  final authenticator = context.read<UserRepository>();

  final user = authenticator.findByUsernameAndPassword(
    username: username.toString(),
    password: password.toString(),
  );
  // password: Encryption.encryptPassword(password.toString()),

  if (user == null) {
    final userN = User(
      username: username.toString(),
      password: '',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    return Response.json(
      body: succcessResponse(
        'User logged in successfully',
        {
          'user': {
            'username': userN.username,
            'tokenExp': Settings.tokenExpirationInHours,
            'token': authenticator.generateToken(
              User(
                username: username.toString(),
                password: '',
                createdAt: '',
                updatedAt: '',
              ),
            ),
          },
        },
      ),
    );
  } else {
    return Response.json(
      body: failedResponse('Account already exist'),
    );
  }
}
