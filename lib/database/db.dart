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
  // Inside your Database class (lib/src/data/database.dart)

  static Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic> substitution = const {},
  }) async {
    final conn = await getConnection();
    try {
      final results = await conn.execute(
        Sql.named(sql),
        parameters: substitution,
      );
      final rows = results.map((row) {
        final columnMap = row.toColumnMap();
        // Iterate through the map and convert any DateTime objects to ISO 8601 strings
        columnMap.forEach((key, value) {
          if (value is DateTime) {
            columnMap[key] = value
                .toIso8601String(); // Converts DateTime to a string like "2025-07-02T03:56:21.640Z"
          }
        });
        return columnMap;
      }).toList();
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
      VALUES (@uid, @title, @description, @created_at, @updated_at)
      RETURNING id, uid, title, description, created_at, updated_at;
      ''',
      substitution: taskData,
    );
    if (results.isNotEmpty) return results.first;
    AppLogger.error('Failed to create task: No rows returned after insert.');
    throw Exception('Failed to create task.');
  }

  static Future<void> updateTask(
    String userUid,
    Map<String, dynamic> taskData,
  ) async {
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

  /// Retrieves all tasks for a specific user.
  static Future<List<Map<String, dynamic>>?> findAllTasksByUserUid(
    String userUid,
  ) async {
    final results = await query(
      'SELECT id, uid, title, description, created_at, updated_at, user_uid FROM tasks WHERE user_uid = @user_uid ORDER BY created_at DESC;',
      substitution: {'user_uid': userUid},
    );
    return results.isNotEmpty ? results : null;
  }

  /// Finds a specific task by its UID, ensuring it belongs to the given user.
  static Future<List<Map<String, dynamic>>?> findTaskByUidAndUserUid(
    String taskUid,
    String userUid,
  ) async {
    final results = await query(
      'SELECT id, uid, title, description, created_at, updated_at, user_uid FROM tasks WHERE uid = @task_uid AND user_uid = @user_uid LIMIT 1;',
      substitution: {'task_uid': taskUid, 'user_uid': userUid},
    );
    return results.isNotEmpty ? results : null;
  }

  /// Creates a new task for a specific user.
  static Future<Map<String, dynamic>> createUserTask(
    Map<String, dynamic> taskData,
    String userUid,
  ) async {
    taskData['user_uid'] = userUid;

    final results = await query(
      '''
      INSERT INTO tasks (uid, title, description, created_at, updated_at, user_uid)
      VALUES (@uid, @title, @description, @created_at, @updated_at, @user_uid)
      RETURNING id, uid, title, description, created_at, updated_at;
      ''',
      substitution: taskData,
    );
    if (results.isNotEmpty) return results.first;
    AppLogger.error('Failed to create task: No rows returned after insert.');
    throw Exception('Failed to create task.');
  }

  /// Updates an existing task, ensuring it belongs to the given user.
  static Future<void> updateUserTask(
    int id,
    String userUid, // New parameter for user_uid
    Map<String, dynamic> taskData,
  ) async {
    taskData['id'] = id;
    taskData['user_uid'] = userUid; // Add user_uid to the substitution map

    await executeDML(
      '''
      UPDATE tasks
      SET title = @title, description = @description, updated_at = @updatedAt
      WHERE id = @id AND user_uid = @user_uid;
      ''',
      substitution: taskData,
    );
  }

  /// Deletes a task, ensuring it belongs to the given user.
  static Future<void> deleteUserTask(
    int id,
    String userUid, // New parameter for user_uid
  ) async {
    await executeDML(
      'DELETE FROM tasks WHERE id = @id AND user_uid = @user_uid;',
      substitution: {'id': id, 'user_uid': userUid},
    );
  }
}
