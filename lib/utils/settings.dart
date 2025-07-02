// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:postgres/postgres.dart';

class Settings {
  // Database Connection Settings
  // These values will be read from environment variables at compile time.
  // The second argument is the default/fallback value if the environment variable is not set.
  // Database Connection Settings
  // Using Platform.environment for runtime access to environment variables
  static String dbHost = Platform.environment['DB_HOST'] ?? '';
  static String dbDatabase = Platform.environment['DB_DATABASE'] ?? '';
  static String dbUsername = Platform.environment['DB_USERNAME'] ?? '';
  static String dbPassword = Platform.environment['DB_PASSWORD'] ?? '';
  static const int dbPort =
      5432; // Standard PostgreSQL port, keep as const unless variable

  // Application Environment Setting
  static String appEnvironment =
      Platform.environment['APP_ENV'] ?? 'development';
  static String authJWTEncodingSecretKey =
      Platform.environment['SECRET_KEY'] ?? '';

  // SSL Mode for PostgreSQL - This is a Dart enum, not directly from environment string by default
  // Keep as const, or add logic to parse from a string env var if you need it configurable.
  static const SslMode dbSslMode = SslMode.require;
  static const int tokenExpirationInHours = 3;

  // You can add a helper to check the environment
  static bool get isProduction => appEnvironment == 'production';
  static bool get isDevelopment => appEnvironment == 'development';
  static bool get isTesting => appEnvironment == 'test';
}
