import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  bool _isSessionExpired = false;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isSessionExpired => _isSessionExpired;
  String? get errorMessage => _errorMessage;

  void clearSessionExpiredFlag() {
    _isSessionExpired = false;
  }

  TaskProvider();

  // Fetch all tasks for current authenticated user
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedTasks = await _taskService.getTasks();
      _tasks = fetchedTasks;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg == 'UNAUTHORIZED') {
        _isSessionExpired = true;
        _errorMessage = 'Session expired. Please log in again.';
      } else {
        _errorMessage = msg;
      }
      notifyListeners();
    }
  }

  // Add new task
  Future<void> addTask(
    String title,
    String description,
    String priority,
    DateTime? dueDate, {
    String status = 'pending',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTask = await _taskService.createTask(
        title: title,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );

      _tasks.insert(0, newTask);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceAll('Exception: ', '');
      _errorMessage = msg == 'UNAUTHORIZED' ? 'Session expired' : msg;
      notifyListeners();
      rethrow;
    }
  }

  // Update task
  Future<void> updateTask(TaskModel updatedTask) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _taskService.updateTask(updatedTask);

      final index = _tasks.indexWhere((t) => t.id == result.id);
      if (index != -1) {
        _tasks[index] = result;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceAll('Exception: ', '');
      _errorMessage = msg == 'UNAUTHORIZED' ? 'Session expired' : msg;
      notifyListeners();
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskService.deleteTask(taskId);

      _tasks.removeWhere((t) => t.id == taskId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceAll('Exception: ', '');
      _errorMessage = msg == 'UNAUTHORIZED' ? 'Session expired' : msg;
      notifyListeners();
      rethrow;
    }
  }

  // Dynamic statistics getters
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.status == 'completed').length;
  int get inProgressTasksCount => _tasks.where((t) => t.status == 'in_progress').length;
  int get pendingTasksCount => _tasks.where((t) => t.status == 'pending').length;
}
