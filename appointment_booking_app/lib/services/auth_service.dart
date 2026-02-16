import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> googleLogin(String googleId, String name, String email, String role) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.googleLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'google_id': googleId,
          'name': name,
          'email': email,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        final token = data['data']['token'];
        final user = User.fromJson(data['data']['user']);

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, token);
        await prefs.setString(Constants.userKey, jsonEncode(user.toJson()));

        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    try {
      print('Attempting login for $email');
      final response = await http.post(
        Uri.parse(Constants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['success']) {
        final token = data['data']['token'];
        final user = User.fromJson(data['data']['user']);

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, token);
        await prefs.setString(Constants.userKey, jsonEncode(user.toJson()));

        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      print('Attempting registration for $email');
      final response = await http.post(
        Uri.parse(Constants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['success']) {
         // Check if token is returned on registration
         if (data['data'] != null && data['data']['token'] != null) {
            final token = data['data']['token'];
            final user = User.fromJson(data['data']['user']);
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(Constants.tokenKey, token);
            await prefs.setString(Constants.userKey, jsonEncode(user.toJson()));
             return {'success': true, 'user': user};
         }
        return {'success': true, 'message': 'Registration successful'};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(Constants.userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}