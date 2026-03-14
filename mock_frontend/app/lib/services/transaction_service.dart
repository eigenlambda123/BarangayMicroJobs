import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class TransactionService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Apply for a job: POST /transactions/apply/{job_id}
  Future<Map<String, dynamic>> applyForJob(String jobId) async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      if (kDebugMode) {
        print('DEBUG: Applying for job: $jobId');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transactions/apply/$jobId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('DEBUG: Apply Status: ${response.statusCode}');
        print('DEBUG: Apply Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? 'Failed to apply for job: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Apply error: $e');
    }
  }

  // Get applicants for a job: GET /transactions/{job_id}/applicants
  Future<List<Map<String, dynamic>>> getApplicants(String jobId) async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$jobId/applicants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> applicantsList = data['applicants'] ?? [];
        return applicantsList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch applicants');
      }
    } catch (e) {
      throw Exception('Get applicants error: $e');
    }
  }

  // Get my transactions: GET /transactions/me
  Future<List<Map<String, dynamic>>> getMyTransactions() async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> transactionsList = data['transactions'] ?? [];
        return transactionsList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      throw Exception('Get transactions error: $e');
    }
  }

  // Cancel transaction: PATCH /transactions/cancel/{transaction_id}
  Future<Map<String, dynamic>> cancelTransaction(String transactionId) async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/transactions/cancel/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? 'Failed to cancel transaction: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Cancel transaction error: $e');
    }
  }
}
