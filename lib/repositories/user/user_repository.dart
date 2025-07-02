// ignore_for_file: public_member_api_docs, always_declare_return_types

import 'package:dart_frog_jwt_neon/database/db.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/utils/encryption.dart';
import 'package:dart_frog_jwt_neon/utils/settings.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class UserRepository {
  static final _users = {
    'john': User(
      username: 'John',
      password: '123',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ),
  };

  Future<User?> verifyToken(String token) async {
    try {
      final payload = JWT.verify(
        token,
        SecretKey(Settings.authJWTEncodingSecretKey),
      );

      final payloadData = payload.payload as Map<String, dynamic>;

      final username = payloadData['username'] as String;

      final user = await findByUsername(
        username: username,
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  String? generateToken(User user) {
    try {
      final token = Encryption.generateToken(user: user);

      return token;
    } catch (e) {
      return null;
    }
  }

  Future<User?> findByUsername({
    required String username,
  }) async {
    final dbLookUp = await Database.findUserByUsername(username);
    if (dbLookUp != null) {
      return User.fromJson(dbLookUp);
    } else {
      return null;
    }
  }

  Future<User?> createUser(User user) async {
    final dbLookUp = await Database.createUser(user.toJson());
    return User.fromJson(dbLookUp);
  }
}
