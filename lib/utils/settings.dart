// ignore_for_file: public_member_api_docs

class Settings {
  // Database Connection Settings
  // These values will be read from environment variables at compile time.
  // The second argument is the default/fallback value if the environment variable is not set.

  static const String dbHost =
      String.fromEnvironment('DB_HOST', defaultValue: 'localhost');

  static const String dbDatabase =
      String.fromEnvironment('DB_DATABASE', defaultValue: 'postgres');

  static const String dbUsername = String.fromEnvironment(
    'DB_USERNAME',
    defaultValue: 'user',
  ); // IMPORTANT: Change default for production!

  static const String dbPassword = String.fromEnvironment(
    'DB_PASSWORD',
    defaultValue: 'pass',
  ); // IMPORTANT: NEVER use default 'pass' in production!

  // Application Environment Setting
  static const String appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  ); // e.g., 'development', 'production', 'test'
  static const String authJWTEncodingSecretKey = String.fromEnvironment(
    'SECRET_KEY',
    defaultValue: 'u98y4tuwbef8o927ty2pi8g7r83fb2',
  );
  static const int tokenExpirationInHours = 3;

  // You can add a helper to check the environment
  static bool get isProduction => appEnvironment == 'production';
  static bool get isDevelopment => appEnvironment == 'development';
  static bool get isTesting => appEnvironment == 'test';
}
