import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RatingService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Rate a provider: POST /ratings/{transaction_id}/rate
  Future<Map<String, dynamic>> rateProvider({
    required String transactionId,
    required int score,
    String? comment,
  }) async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/ratings/$transactionId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'score': score,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to submit rating');
      }
    } catch (e) {
      throw Exception('Rate provider error: $e');
    }
  }

  // Get provider ratings: GET /ratings/providers/{provider_id}
  Future<Map<String, dynamic>> getProviderRatings(String providerId) async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/ratings/providers/$providerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch ratings');
      }
    } catch (e) {
      throw Exception('Get ratings error: $e');
    }
  }
}
