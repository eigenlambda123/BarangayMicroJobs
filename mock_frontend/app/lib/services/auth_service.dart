import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Register endpoint: POST /auth/register
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'phone_number': phoneNumber,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Login endpoint: POST /auth/login
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store token and user info
        await _saveToken(data['access_token']);
        await _saveUserId(data['user']['id'].toString());

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Get current user endpoint: GET /auth/me
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await logout();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  // Token management
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await logout();
      }

      return false;
    } catch (_) {
      // Keep the user signed in during transient connectivity issues.
      return true;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Update profile image endpoint: PUT /auth/me/profile-image
  Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/me/profile-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        final error = jsonDecode(responseBody);
        throw Exception(error['detail'] ?? 'Failed to update profile image');
      }
    } catch (e) {
      throw Exception('Update profile image error: $e');
    }
  }

  // Update profile endpoint: PUT /auth/profile
  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? email,
    String? location,
    List<String>? skills,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final body = <String, dynamic>{};
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (location != null) body['location'] = location;
      if (skills != null) body['skills'] = skills;

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }
}
