import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_jwt_neon/repositories/user/user_repository.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider((context) => UserRepository()));
}
