// lib/routes/tasks/_middleware.dart

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/repositories/user/user_repository.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(
    bearerAuthentication<User>(
      authenticator: (context, token) async {
        final authenticator = context.read<UserRepository>();
        return authenticator.verifyToken(token);
      },
    ),
  );
}
