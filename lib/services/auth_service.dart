import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/api_config.dart';

class AuthService {
  // Login method
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'] as String;
        final userData = responseData['user'] as Map<String, dynamic>;
        
        return UserModel.fromJson(userData).copyWith(token: token);
      } else {
        final message = responseData['message'] ?? 'Authentication failed';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server. Please check your network connection.');
    }
  }

  // Register method
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final token = responseData['token'] as String;
        final userData = responseData['user'] as Map<String, dynamic>;

        return UserModel.fromJson(userData).copyWith(token: token);
      } else {
        final message = responseData['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server. Please check your network connection.');
    }
  }

  // Get current user profile (/api/auth/me)
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getMeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(responseData).copyWith(token: token);
      } else {
        final message = responseData['message'] ?? 'Session expired';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to validate user session');
    }
  }
}
