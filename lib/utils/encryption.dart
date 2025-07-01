// ignore_for_file: public_member_api_docs

import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/utils/settings.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Encryption {
  static String generateToken({
    required User user,
  }) {
    final jwt = JWT(
      {
        'username': user.username,
      },
    );

    return jwt.sign(
      SecretKey(Settings.authJWTEncodingSecretKey),
      expiresIn: const Duration(hours: Settings.tokenExpirationInHours),
    );
  }

  static Map<dynamic, dynamic> verifyToken(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(Settings.authJWTEncodingSecretKey),
    );
    return jwt.payload as Map;
  }
}
