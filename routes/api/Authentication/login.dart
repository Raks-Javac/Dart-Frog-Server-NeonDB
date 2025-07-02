import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/repositories/user/user_repository.dart';
import 'package:dart_frog_jwt_neon/utils/encryption.dart';
import 'package:dart_frog_jwt_neon/utils/logger.dart';
import 'package:dart_frog_jwt_neon/utils/settings.dart';
import 'package:dart_frog_jwt_neon/utils/utils.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _loginUser(context),
    _ => Future.value(
        Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: failedResponse('Request not allowed'),
        ),
      ),
  };
}

Future<Response> _loginUser(RequestContext context) async {
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

  final user = await authenticator.findByUsername(
    username: username.toString(),
  );

  if (user == null) {
    return Response.json(
      body: failedResponse(
        'User not found, Kindly register to create an account',
      ),
    );
  } else {
    AppLogger.info('Pw gotten from DB ${user.password}');
    AppLogger.info(
      'Pw gotten from DB enc ${Encryption.encryptPassword(password.toString())}',
    );
    if (!Encryption.checkPassword(
          password.toString(),
          user.password.toString(),
        ) &&
        user.username.toString() == username.toString()) {
      return Response.json(
        body: failedResponse('Invalid Credentials'),
      );
    }
    return Response.json(
      body: succcessResponse(
        'User Logged in successfully',
        {
          'user': {
            'username': username,
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
  }
}
