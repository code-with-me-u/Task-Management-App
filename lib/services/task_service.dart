import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../utils/api_config.dart';
import '../utils/constants.dart';

class TaskService {
  // Helper to retrieve token from shared_preferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('UNAUTHORIZED');
    }
    return token;
  }

  // Get all tasks for current authenticated user
  Future<List<TaskModel>> getTasks() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.tasksUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => TaskModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to fetch tasks');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server. Please check your network connection.');
    }
  }

  // Get single task by ID
  Future<TaskModel> getTaskById(String id) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksUrl}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Task not found');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server');
    }
  }

  // Create new task
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String priority,
    required String status,
    DateTime? dueDate,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiConfig.tasksUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title.trim(),
          'description': description.trim(),
          'priority': priority,
          'status': status,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to create task');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server');
    }
  }

  // Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.tasksUrl}/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toPayloadJson()),
      );

      if (response.statusCode == 200) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to update task');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server');
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.tasksUrl}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to delete task');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server');
    }
  }
}
