// ignore_for_file: public_member_api_docs

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/utils/logger.dart';
import 'package:dart_frog_jwt_neon/utils/settings.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Encryption {
  static String generateToken({
    required User user,
  }) {
    final jwt = JWT(
      {
        'username': user.username,
        'uid': user.uid,
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

  static String encryptPassword(String pw, {int costFactor = 10}) {
    // Validate cost factor to be within bcrypt's acceptable range
    if (costFactor < 4 || costFactor > 31) {
      AppLogger.debug(
        'Warning: Invalid bcrypt cost factor ($costFactor). Reverting to default of 10.',
      );
    }

    try {
      // BCrypt.gensalt() generates a random salt. The 'rounds' parameter
      // sets the work factor (cost).
      final salt = BCrypt.gensalt(logRounds: costFactor);

      // BCrypt.hashpw() combines the plain string with the salt and hashes it.
      final hashedPassword = BCrypt.hashpw(pw, salt);

      return hashedPassword;
    } catch (e) {
      AppLogger.warning('Error hashing string with bcrypt: $e');
      return '';
    }
  }

  static bool checkPassword(String pw, String hashedPwFromDb) {
    return BCrypt.checkpw(pw, hashedPwFromDb);
  }
}
