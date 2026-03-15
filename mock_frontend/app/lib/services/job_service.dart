import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class JobService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Create job post: POST /jobs/create
  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String location,
    required String salary,
    String? image,
  }) async {
    try {
      final token = await AuthService().getToken();

      if (kDebugMode) {
        print('DEBUG: Token retrieved: $token');
      }

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      if (kDebugMode) {
        print('DEBUG: Headers: $headers');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/jobs/create'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'location': location,
          'salary': salary,
          if (image != null && image.isNotEmpty) 'image': image,
        }),
      );

      if (kDebugMode) {
        print('DEBUG: Status: ${response.statusCode}');
        print('DEBUG: Response: ${response.body}');
      }

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? 'Failed to create job: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Job creation error: $e');
    }
  }

  // Get all jobs: GET /jobs/
  Future<List<Map<String, dynamic>>> getAllJobs() async {
    try {
      final token = await AuthService().getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/jobs/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jobs = jsonDecode(response.body);
        return jobs.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Get jobs error: $e');
    }
  }

  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> job = jsonDecode(response.body);
        return job;
      } else {
        throw Exception('Failed to fetch job');
      }
    } catch (e) {
      throw Exception('Get job error: $e');
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete job');
      }
    } catch (e) {
      throw Exception('Delete job error: $e');
    }
  }
}
