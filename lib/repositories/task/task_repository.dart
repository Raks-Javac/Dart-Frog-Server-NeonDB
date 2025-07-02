import 'package:dart_frog_jwt_neon/database/db.dart';
import 'package:dart_frog_jwt_neon/models/task/task_model.dart';

class TaskRepository {
  Future<List<Map<dynamic, dynamic>>> getAll() async {
    return Database.findAllTasks();
  }

  // You would add other task-related methods here;
  Future<Map<String, dynamic>> create(Task task) =>
      Database.createTask(task.toJson());
  Future<void> update(Task task) => Database.updateTask(task.toJson());
  Future<void> delete(int id) => Database.deleteTask(id);

  Future<Map<String, dynamic>?> findByUid(String uid) =>
      Database.findTaskByUid(uid);
}
