// ignore_for_file: public_member_api_docs

import 'package:dart_frog_jwt_neon/database/db.dart';
import 'package:dart_frog_jwt_neon/models/task/task_model.dart';

class TaskRepository {
  Future<List<Map<dynamic, dynamic>>> getAll() async {
    return Database.findAllTasks();
  }

  // You would add other task-related methods here;
  Future<Map<String, dynamic>> create(String userUid, Task task) =>
      Database.createUserTask(task.toJson(), userUid);
  Future<void> update(String userUid, Task task) =>
      Database.updateTask(userUid, task.toJson());
  Future<void> delete(int id) => Database.deleteTask(id);

  Future<Map<String, dynamic>?> findByUid(String uid) =>
      Database.findTaskByUid(uid);

  Future<List<Map<String, dynamic>>?> findAllTaskByUserUid(String uid) =>
      Database.findAllTasksByUserUid(
        uid,
      );
}
