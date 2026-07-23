import 'package:flutter/foundation.dart';

class ApiConfig {
  // Base URL resolution based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    // Android Emulator host loopback address
    return 'http://10.0.2.2:5000/api';
  }

  // Endpoints
  static String get registerUrl => '$baseUrl/auth/register';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get getMeUrl => '$baseUrl/auth/me';
  static String get tasksUrl => '$baseUrl/tasks';
}
