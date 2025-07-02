import 'package:dart_frog_jwt_neon/database/db.dart';
import 'package:dart_frog_jwt_neon/utils/logger.dart';

void main(List<String> arguments) async {
  AppLogger.info('Starting database migration...');

  try {
    // 1. Establish database connection
    await Database.getConnection();
    AppLogger.info('Database connection established for migration.');

    // --- MIGRATION STEPS ---
    // Execute these queries one by one.
    // It's good practice to make them idempotent (can be run multiple times without error)
    // using IF NOT EXISTS or handling specific error codes.

    // Example 1: Create 'users' table (if it doesn't exist)
    AppLogger.info('Attempting to create users table...');
    await Database.executeDML('''
      CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          uid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
          username VARCHAR(255) UNIQUE NOT NULL,
          password TEXT NOT NULL,
          created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    AppLogger.info('Users table ensured.');

    // Example 2: Create 'tasks' table (if it doesn't exist)
    AppLogger.info('Attempting to create tasks table...');
    await Database.executeDML('''
      CREATE TABLE IF NOT EXISTS tasks (
          id SERIAL PRIMARY KEY,
          uid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
          title VARCHAR(255) NOT NULL,
          description TEXT,
          created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
          user_uid UUID NOT NULL -- This column will store the user's UUID
      );
    ''');
    AppLogger.info('Tasks table ensured.');

    // Example 3: Add Foreign Key Constraint to tasks.user_uid (if it doesn't exist)
    // This is typically added after both tables exist.
    // We wrap it in a transaction because ALTER TABLE can be sensitive.
    // You'd need to check if the constraint exists before adding to avoid errors on re-run.
    // For simplicity, we'll just try to add it, catching errors if it exists.
    // A more robust migration system would query pg_constraint to check for existence first.
    try {
      AppLogger.info(
        'Attempting to add foreign key constraint to tasks.user_uid...',
      );
      await Database.executeDML('''
        ALTER TABLE tasks
        ADD CONSTRAINT fk_tasks_user_uid
        FOREIGN KEY (user_uid) REFERENCES users (uid)
        ON DELETE CASCADE;
      ''');
      AppLogger.info('Foreign key constraint added to tasks.user_uid.');
    } catch (e) {
      AppLogger.warning(
        'Foreign key constraint might already exist or failed to add: $e',
      );
    }

    // Example 4: Drop UNIQUE constraint from tasks.user_uid if it exists (from previous error)
    try {
      AppLogger.info(
        'Attempting to drop unique constraint on tasks.user_uid...',
      );
      await Database.executeDML('''
        ALTER TABLE tasks
        DROP CONSTRAINT IF EXISTS tasks_user_uid_key;
      ''');
      AppLogger.info(
        'Unique constraint "tasks_user_uid_key" dropped if it existed.',
      );
    } catch (e) {
      // This catch is less likely needed with IF EXISTS, but good for specific error handling
      AppLogger.warning(
        "Failed to drop unique constraint, possibly because it didn't exist or other error: $e",
      );
    }

    AppLogger.info('Database migration completed successfully!');
  } catch (e, st) {
    AppLogger.error('Database migration failed!', e, st);
    // Exit with a non-zero code to indicate failure in CI/CD environments
    await Database.closeConnection();
    // exit(1); // Consider uncommenting this in production/CI for clear failure
  } finally {
    // Ensure connection is closed even on success
    await Database.closeConnection();
  }
}
