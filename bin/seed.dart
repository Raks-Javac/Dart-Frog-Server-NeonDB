import 'package:bcrypt/bcrypt.dart'; // For hashing passwords
import 'package:dart_frog_jwt_neon/database/db.dart';
import 'package:dart_frog_jwt_neon/models/task/task_model.dart';
import 'package:dart_frog_jwt_neon/models/user/user_model.dart';
import 'package:dart_frog_jwt_neon/utils/logger.dart';

void main(List<String> arguments) async {
  AppLogger.info('Starting database seeding...');

  try {
    await Database.getConnection();
    AppLogger.info('Database connection established for seeding.');

    // --- SEEDING STEPS ---
    // Example: Create a default admin user if one doesn't exist
    final existingAdmin = await Database.findUserByUsername('admin');
    if (existingAdmin == null) {
      AppLogger.info('Creating default admin user...');
      final hashedPassword = BCrypt.hashpw('adminpassword', BCrypt.gensalt());
      final adminUser = User(
        username: 'admin',
        password: hashedPassword,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final createdAdmin = await Database.createUser(adminUser.toJson());
      AppLogger.info('Admin user created with UID: ${createdAdmin['uid']}');

      // Example: Create some tasks for the admin user
      AppLogger.info('Creating sample tasks for admin user...');
      await Database.createUserTask(
        Task(
          title: 'Learn Dart Frog',
          description: 'Explore routing and middleware',
        ).toJson(),
        createdAdmin['uid'] as String,
      );
      await Database.createUserTask(
        Task(
          title: 'Build API Endpoints',
          description: 'Implement user and task CRUD',
        ).toJson(),
        createdAdmin['uid'] as String,
      );
      AppLogger.info('Sample tasks created for admin.');
    } else {
      AppLogger.info('Admin user already exists. Skipping creation.');
    }

    AppLogger.info('Database seeding completed successfully!');
  } catch (e, st) {
    AppLogger.error('Database seeding failed!', e, st);
    // exit(1); // Uncomment in production/CI
  } finally {
    await Database.closeConnection();
  }
}
