// import 'package:dart_frog_jwt_neon/utils/logger.dart'; // Your custom logger
// import 'package:dart_frog_jwt_neon/utils/settings.dart'; // Your settings
// import 'package:postgres/postgres.dart';

// class Database {
//   Database._privateConstructor();
//   static Connection? _connection;

//   static Future<Connection> getConnection() async {
//     if (_connection == null || !(_connection?.isOpen ?? false)) {
//       try {
//         _connection = await Connection.open(
//           Endpoint(
//             host: Settings.dbHost,
//             database: Settings.dbDatabase,
//             username: Settings.dbUsername,
//             password: Settings.dbPassword,
//           ),
//           settings: const ConnectionSettings(
//             sslMode: SslMode.disable, // Configure SSL as needed for production
//           ),
//         );
//         AppLogger.info('Database connection established.');
//       } catch (e, st) {
//         AppLogger.error('Error establishing database connection', e, st);
//         rethrow;
//       }
//     }
//     return _connection!;
//   }

//   static Future<void> closeConnection() async {
//     if (_connection != null && _connection!.isOpen) {
//       try {
//         await _connection!.close();
//         _connection = null;
//         AppLogger.info('Database connection closed.');
//       } catch (e, st) {
//         AppLogger.error('Error closing database connection', e, st);
//       }
//     }
//   }

//   /// Executes a SQL statement (INSERT, UPDATE, DELETE). Returns affected row count.
//   static Future<int> execute(
//     String sql, {
//     Map<String, dynamic> substitution = const {},
//   }) async {
//     final conn = await getConnection();
//     try {
//       final result = await conn.execute(
//         Sql.named(sql),
//         parameters: substitution,
//       );
//       AppLogger.debug('SQL execute: $sql - Affected: ${result.affectedRows}');
//       return result.affectedRows;
//     } catch (e, st) {
//       AppLogger.error(
//         'DB execute error: "$sql" - Params: $substitution',
//         e,
//         st,
//       );
//       rethrow;
//     }
//   }

//   /// Queries data from the database (SELECT). Returns list of column maps.
//   static Future<List<Map<String, dynamic>>> query(
//     String sql, {
//     Map<String, dynamic> substitution = const {},
//   }) async {
//     final conn = await getConnection();
//     try {
//       final results = await conn.execute(
//         // Using execute as per latest docs interpretation
//         Sql.named(sql),
//         parameters: substitution,
//       );
//       final rows = results.map((row) => row.toColumnMap()).toList();
//       AppLogger.debug('SQL query: "$sql" - Rows: ${rows.length}');
//       return rows;
//     } catch (e, st) {
//       AppLogger.error('DB query error: "$sql" - Params: $substitution', e, st);
//       rethrow;
//     }
//   }

//   /// Runs a series of operations within a transaction.
//   static Future<T> runTransaction<T>(
//     Future<T> Function(Session session) transactionOperations,
//   ) async {
//     final conn = await getConnection();
//     try {
//       AppLogger.info('Transaction started.');
//       final result = await conn.runTx((ctx) async {
//         return transactionOperations(ctx);
//       });
//       AppLogger.info('Transaction committed.');
//       return result;
//     } catch (e, st) {
//       AppLogger.error('Transaction failed', e, st);
//       rethrow;
//     }
//   }

//   // --- Specific Reusable Functions for Users Table ---

//   static Future<Map<String, dynamic>?> findUserByUsername(
//     String username,
//   ) async {
//     final results = await query(
//       'SELECT id, uid, username, password, created_at, updated_at FROM users WHERE username = @username LIMIT 1;',
//       substitution: {'username': username},
//     );
//     return results.isNotEmpty ? results.first : null;
//   }

//   static Future<Map<String, dynamic>?> findUserByUid(String uid) async {
//     final results = await query(
//       'SELECT id, uid, username, password, created_at, updated_at FROM users WHERE uid = @uid LIMIT 1;',
//       substitution: {'uid': uid},
//     );
//     return results.isNotEmpty ? results.first : null;
//   }

//   static Future<Map<String, dynamic>> createUser(
//     Map<String, dynamic> userData,
//   ) async {
//     final results = await query(
//       '''
//       INSERT INTO users (uid, username, password, created_at, updated_at)
//       VALUES (@uid, @username, @password, @createdAt, @updatedAt)
//       RETURNING id, uid, username, password, created_at, updated_at;
//       ''',
//       substitution: userData,
//     );
//     if (results.isNotEmpty) return results.first;
//     AppLogger.error('Failed to create user: No rows returned after insert.');
//     throw Exception('Failed to create user.');
//   }

//   static Future<int> updateUser(int id, Map<String, dynamic> userData) async {
//     userData['id'] = id; // Ensure ID is in substitution map
//     final affectedRows = await execute(
//       '''
//       UPDATE users
//       SET username = @username, password = @password, updated_at = @updatedAt
//       WHERE id = @id;
//       ''',
//       substitution: userData,
//     );
//     return affectedRows;
//   }

//   static Future<int> deleteUser(int id) async {
//     return execute(
//       'DELETE FROM users WHERE id = @id;',
//       substitution: {'id': id},
//     );
//   }

//   // --- Specific Reusable Functions for Tasks Table ---

//   static Future<Map<String, dynamic>?> findTaskByUid(String uid) async {
//     final results = await query(
//       'SELECT id, uid, title, description, created_at, updated_at FROM tasks WHERE uid = @uid LIMIT 1;',
//       substitution: {'uid': uid},
//     );
//     return results.isNotEmpty ? results.first : null;
//   }

//   static Future<List<Map<String, dynamic>>> findAllTasks() async {
//     return query(
//       'SELECT id, uid, title, description, created_at, updated_at FROM tasks ORDER BY created_at DESC;',
//     );
//   }

//   static Future<Map<String, dynamic>> createTask(
//     Map<String, dynamic> taskData,
//   ) async {
//     final results = await query(
//       '''
//       INSERT INTO tasks (uid, title, description, created_at, updated_at)
//       VALUES (@uid, @title, @description, @createdAt, @updatedAt)
//       RETURNING id, uid, title, description, created_at, updated_at;
//       ''',
//       substitution: taskData,
//     );
//     if (results.isNotEmpty) return results.first;
//     AppLogger.error('Failed to create task: No rows returned after insert.');
//     throw Exception('Failed to create task.');
//   }

//   static Future<int> updateTask(int id, Map<String, dynamic> taskData) async {
//     taskData['id'] = id; // Ensure ID is in substitution map
//     final affectedRows = await execute(
//       '''
//       UPDATE tasks
//       SET title = @title, description = @description, updated_at = @updatedAt
//       WHERE id = @id;
//       ''',
//       substitution: taskData,
//     );
//     return affectedRows;
//   }

//   static Future<int> deleteTask(int id) async {
//     return execute(
//       'DELETE FROM tasks WHERE id = @id;',
//       substitution: {'id': id},
//     );
//   }
// }

// ignore_for_file: public_member_api_docs

import 'package:dart_frog_jwt_neon/utils/logger.dart';
import 'package:dart_frog_jwt_neon/utils/settings.dart';
import 'package:postgres/postgres.dart';

class Database {
  Database._privateConstructor();
  static Connection? _connection;

  static Future<Connection> getConnection() async {
    if (_connection == null || !(_connection?.isOpen ?? false)) {
      try {
        _connection = await Connection.open(
          Endpoint(
            host: Settings.dbHost,
            database: Settings.dbDatabase,
            username: Settings.dbUsername,
            password: Settings.dbPassword,
          ),
          settings: const ConnectionSettings(
            sslMode: SslMode.disable,
          ),
        );
        AppLogger.info('Database connection established.');
      } catch (e, st) {
        AppLogger.error('Error establishing database connection', e, st);
        rethrow;
      }
    }
    return _connection!;
  }

  static Future<void> closeConnection() async {
    if (_connection != null && _connection!.isOpen) {
      try {
        await _connection!.close();
        _connection = null;
        AppLogger.info('Database connection closed.');
      } catch (e, st) {
        AppLogger.error('Error closing database connection', e, st);
      }
    }
  }

  /// Executes a SQL statement (INSERT, UPDATE, DELETE).
  static Future<void> executeDML(
    String sql, {
    Map<String, dynamic> substitution = const {},
  }) async {
    final conn = await getConnection();
    try {
      await conn.execute(
        Sql.named(sql),
        parameters: substitution,
      );
      AppLogger.debug('SQL DML executed: $sql');
    } catch (e, st) {
      AppLogger.error('DB DML error: "$sql" - Params: $substitution', e, st);
      rethrow;
    }
  }

  /// Queries data from the database (SELECT). Returns list of column maps.
  static Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic> substitution = const {},
  }) async {
    final conn = await getConnection();
    try {
      // Using conn.execute for SELECT as per your preference and screenshot
      final results = await conn.execute(
        Sql.named(sql),
        parameters: substitution,
      );
      final rows = results.map((row) => row.toColumnMap()).toList();
      AppLogger.debug('SQL query: "$sql" - Rows: ${rows.length}');
      return rows;
    } catch (e, st) {
      AppLogger.error('DB query error: "$sql" - Params: $substitution', e, st);
      rethrow;
    }
  }

  /// Runs a series of operations within a transaction.
  static Future<T> runTransaction<T>(
    Future<T> Function(Session session) transactionOperations,
  ) async {
    final conn = await getConnection();
    try {
      AppLogger.info('Transaction started.');
      final result = await conn.runTx((ctx) async {
        return transactionOperations(ctx);
      });
      AppLogger.info('Transaction committed.');
      return result;
    } catch (e, st) {
      AppLogger.error('Transaction failed', e, st);
      rethrow;
    }
  }

  // --- Specific Reusable Functions for Users Table ---

  static Future<Map<String, dynamic>?> findUserByUsername(
    String username,
  ) async {
    final results = await query(
      'SELECT id, uid, username, password, created_at, updated_at FROM users WHERE username = @username LIMIT 1;',
      substitution: {'username': username},
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<Map<String, dynamic>?> findUserByUid(String uid) async {
    final results = await query(
      'SELECT id, uid, username, password, created_at, updated_at FROM users WHERE uid = @uid LIMIT 1;',
      substitution: {'uid': uid},
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData,
  ) async {
    final results = await query(
      // Use query with RETURNING
      '''
      INSERT INTO users (uid, username, password, created_at, updated_at)
      VALUES (@uid, @username, @password, @created_at, @updated_at)
      RETURNING id, uid, username, password, created_at, updated_at;
      ''',
      substitution: userData,
    );
    if (results.isNotEmpty) return results.first;
    AppLogger.error('Failed to create user: No rows returned after insert.');
    throw Exception('Failed to create user.');
  }

  static Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    userData['id'] = id;
    await executeDML(
      '''
      UPDATE users
      SET username = @username, password = @password, updated_at = @updatedAt
      WHERE id = @id;
      ''',
      substitution: userData,
    );
  }

  static Future<void> deleteUser(int id) async {
    await executeDML(
      'DELETE FROM users WHERE id = @id;',
      substitution: {'id': id},
    );
  }

  // --- Specific Reusable Functions for Tasks Table ---

  static Future<Map<String, dynamic>?> findTaskByUid(String uid) async {
    final results = await query(
      'SELECT id, uid, title, description, created_at, updated_at FROM tasks WHERE uid = @uid LIMIT 1;',
      substitution: {'uid': uid},
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<List<Map<String, dynamic>>> findAllTasks() async {
    return query(
      'SELECT id, uid, title, description, created_at, updated_at FROM tasks ORDER BY created_at DESC;',
    );
  }

  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    final results = await query(
      // Use query with RETURNING
      '''
      INSERT INTO tasks (uid, title, description, created_at, updated_at)
      VALUES (@uid, @title, @description, @createdAt, @updatedAt)
      RETURNING id, uid, title, description, created_at, updated_at;
      ''',
      substitution: taskData,
    );
    if (results.isNotEmpty) return results.first;
    AppLogger.error('Failed to create task: No rows returned after insert.');
    throw Exception('Failed to create task.');
  }

  static Future<void> updateTask(Map<String, dynamic> taskData) async {
    await executeDML(
      '''
      UPDATE tasks
      SET title = @title, description = @description, updated_at = @updatedAt
      WHERE id = @id;
      ''',
      substitution: taskData,
    );
  }

  static Future<void> deleteTask(int id) async {
    await executeDML(
      'DELETE FROM tasks WHERE id = @id;',
      substitution: {'id': id},
    );
  }
}
