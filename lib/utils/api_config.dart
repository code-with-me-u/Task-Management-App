class ApiConfig {
  // Production backend deployed on Render
  static const String baseUrl =
      'https://task-management-app-backend-zb6m.onrender.com/api';

  // Authentication endpoints
  static String get registerUrl => '$baseUrl/auth/register';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get getMeUrl => '$baseUrl/auth/me';

  // Task endpoints
  static String get tasksUrl => '$baseUrl/tasks';
}
