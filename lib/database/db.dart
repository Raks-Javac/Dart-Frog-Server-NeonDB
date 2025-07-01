// ignore_for_file: public_member_api_docs

import 'package:postgres/postgres.dart';

class Database {
  // Private constructor to prevent external instantiation.
  Database._privateConstructor();
  // Static variable to hold the single database connection instance.
  static Connection? _connection;

  // Static method to get the database connection.
  // It ensures only one connection is open at a time.
  static Future<Connection> getConnection() async {
    // If the connection is null or not open, try to establish/re-establish it.
    if (_connection == null || !(_connection?.isOpen ?? false)) {
      try {
        _connection = await Connection.open(
          Endpoint(
            host: 'localhost',
            database: 'postgres',
            username: 'user', // Replace with your actual username
            password: 'pass', // Replace with your actual password
          ),
        );
        ('Database connection established/re-established.');
      } catch (e) {
        print('Error establishing database connection: $e');
        // Optionally re-throw the error or handle it as appropriate for your app
        rethrow;
      }
    }
    return _connection!;
  }

  // Static method to close the database connection when the application shuts down.
  static Future<void> closeConnection() async {
    if (_connection != null && _connection!.isOpen) {
      await _connection!.close();
      _connection = null;
      print('Database connection closed.');
    }
  }
}
