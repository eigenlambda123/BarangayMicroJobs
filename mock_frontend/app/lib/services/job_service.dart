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
    String? imagePath,
  }) async {
    try {
      final token = await AuthService().getToken();

      if (kDebugMode) {
        print('DEBUG: Token retrieved: $token');
      }

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/jobs/create-with-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['location'] = location;
      request.fields['salary'] = salary;
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('DEBUG: Status: ${response.statusCode}');
        print('DEBUG: Response: $responseBody');
      }

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        final error = jsonDecode(responseBody);
        throw Exception(
          error['detail'] ?? 'Failed to create job: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Job creation error: $e');
    }
  }

  // Get all jobs: GET /jobs/
  Future<List<Map<String, dynamic>>> getAllJobs({
    String? query,
    String? location,
    String? status,
    String? minSalary,
    String? maxSalary,
    String? skills,
  }) async {
    try {
      final token = await AuthService().getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final queryParams = <String, String>{
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (minSalary != null && minSalary.trim().isNotEmpty)
          'min_salary': minSalary.trim(),
        if (maxSalary != null && maxSalary.trim().isNotEmpty)
          'max_salary': maxSalary.trim(),
        if (skills != null && skills.trim().isNotEmpty) 'skills': skills.trim(),
      };

      final uri = Uri.parse(
        '$baseUrl/jobs/',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri, headers: headers);

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

  // Update job: PUT /jobs/{job_id}
  Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? location,
    String? salary,
    String? image,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (location != null) body['location'] = location;
      if (salary != null) body['salary'] = salary;
      if (image != null) body['image'] = image;

      final response = await http.put(
        Uri.parse('$baseUrl/jobs/$jobId'),
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
        throw Exception(error['detail'] ?? 'Failed to update job');
      }
    } catch (e) {
      throw Exception('Update job error: $e');
    }
  }
}
