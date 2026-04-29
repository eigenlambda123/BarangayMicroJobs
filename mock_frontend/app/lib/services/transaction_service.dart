import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';
import 'offline_sync_service.dart';

class TransactionService {
  static const String baseUrl = ApiConfig.baseUrl;

  String _transactionKey(Map<String, dynamic> transaction) {
    final jobId = transaction['job'] is Map
        ? transaction['job']['id']?.toString()
        : '';
    final providerId = transaction['provider'] is Map
        ? transaction['provider']['id']?.toString()
        : '';
    final requesterId = transaction['requester'] is Map
        ? transaction['requester']['id']?.toString()
        : '';
    final isRequester = transaction['is_requester'] == true ? '1' : '0';
    return '$jobId|$providerId|$requesterId|$isRequester';
  }

  Future<Map<String, dynamic>> _queueApplyForJob(String jobId) async {
    final userId = await AuthService().getUserId();
    final localId =
        'local-transaction-${DateTime.now().microsecondsSinceEpoch}';
    final placeholder = <String, dynamic>{
      'id': localId,
      'job': {
        'id': jobId,
        'title': 'Pending application',
        'salary': 0,
        'location': '',
        'status': 'open',
      },
      'provider': {'id': userId, 'name': 'You'},
      'requester': {'id': '', 'name': ''},
      'status': 'applied',
      'accepted_at': DateTime.now().toIso8601String(),
      'completed_at': null,
      'is_requester': false,
      'requester_completed': false,
      'provider_completed': false,
      'requester_canceled': false,
      'provider_canceled': false,
      'sync_status': 'pending',
    };

    await OfflineSyncService.instance.queueAction(
      OfflineQueuedAction(
        id: 'apply-$localId',
        type: OfflineActionType.applyForJob,
        payload: {'localId': localId, 'jobId': jobId},
        createdAt: DateTime.now(),
        retryCount: 0,
      ),
    );

    await OfflineSyncService.instance.upsertCachedTransaction(placeholder);
    return {
      'transaction_id': localId,
      'queued': true,
      'message':
          'Application saved offline and will sync when you are back online.',
    };
  }

  Future<Map<String, dynamic>> applyForJob(String jobId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      if (kDebugMode) {
        print('DEBUG: Applying for job: $jobId');
      }

      if (!await OfflineSyncService.instance.hasConnection()) {
        return _queueApplyForJob(jobId);
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
        await getMyTransactions();
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        error['detail'] ?? 'Failed to apply for job: ${response.statusCode}',
      );
    } on SocketException catch (_) {
      return _queueApplyForJob(jobId);
    } on TimeoutException catch (_) {
      return _queueApplyForJob(jobId);
    } on http.ClientException catch (_) {
      return _queueApplyForJob(jobId);
    } catch (e) {
      throw Exception('Apply error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getApplicants(
    String jobId, {
    String? query,
    String? status,
    String? minRating,
    String? minJobsDone,
    String? skills,
  }) async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final queryParams = <String, String>{
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (minRating != null && minRating.trim().isNotEmpty)
          'min_rating': minRating.trim(),
        if (minJobsDone != null && minJobsDone.trim().isNotEmpty)
          'min_jobs_done': minJobsDone.trim(),
        if (skills != null && skills.trim().isNotEmpty) 'skills': skills.trim(),
      };

      final uri = Uri.parse(
        '$baseUrl/transactions/$jobId/applicants',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> applicantsList = data['applicants'] ?? [];
        return applicantsList.cast<Map<String, dynamic>>();
      }

      throw Exception('Failed to fetch applicants');
    } catch (e) {
      throw Exception('Get applicants error: $e');
    }
  }

  Future<Map<String, dynamic>> hireProvider(String transactionId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      if (!await OfflineSyncService.instance.hasConnection()) {
        await OfflineSyncService.instance.queueAction(
          OfflineQueuedAction(
            id: 'hire-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
            type: OfflineActionType.hireProvider,
            payload: {'transactionId': transactionId},
            createdAt: DateTime.now(),
            retryCount: 0,
          ),
        );
        return {'queued': true, 'message': 'Hire action queued for sync.'};
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/transactions/hire/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await getMyTransactions();
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        error['detail'] ?? 'Failed to hire provider: ${response.statusCode}',
      );
    } on SocketException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'hire-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.hireProvider,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Hire action queued for sync.'};
    } on TimeoutException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'hire-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.hireProvider,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Hire action queued for sync.'};
    } on http.ClientException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'hire-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.hireProvider,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Hire action queued for sync.'};
    } catch (e) {
      throw Exception('Hire provider error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMyTransactions({
    String? query,
    String? status,
    String? location,
    String? role,
  }) async {
    try {
      final cachedTransactions = await OfflineSyncService.instance
          .getCachedTransactions();
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      final queryParams = <String, String>{
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
      };

      final uri = Uri.parse(
        '$baseUrl/transactions/me',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> transactionsList = data['transactions'] ?? [];
        final serverTransactions = transactionsList
            .cast<Map<String, dynamic>>();
        final pendingTransactions = cachedTransactions.where((transaction) {
          final syncStatus = (transaction['sync_status'] ?? '').toString();
          return syncStatus.isNotEmpty && syncStatus != 'synced';
        }).toList();

        final mergedTransactions = <Map<String, dynamic>>[
          ...serverTransactions,
        ];
        for (final pending in pendingTransactions) {
          final pendingKey = _transactionKey(pending);
          final pendingId = pending['id']?.toString() ?? '';
          final aliasId = await OfflineSyncService.instance.resolveAlias(
            entityType: 'transaction',
            localId: pendingId,
          );
          final hasAlias =
              aliasId != null && aliasId.isNotEmpty && aliasId != pendingId;
          final existingIndex = mergedTransactions.indexWhere(
            (transaction) => _transactionKey(transaction) == pendingKey,
          );
          if (existingIndex == -1) {
            mergedTransactions.add(pending);
          } else if (!hasAlias && pending['sync_status'] != 'pending_delete') {
            mergedTransactions[existingIndex] = pending;
          }
        }

        await OfflineSyncService.instance.cacheTransactions(mergedTransactions);
        return mergedTransactions;
      }

      throw Exception('Failed to fetch transactions');
    } catch (e) {
      final cachedTransactions = await OfflineSyncService.instance
          .getCachedTransactions();
      if (cachedTransactions.isNotEmpty) {
        return cachedTransactions;
      }
      throw Exception('Get transactions error: $e');
    }
  }

  Future<Map<String, dynamic>> cancelTransaction(String transactionId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      if (!await OfflineSyncService.instance.hasConnection()) {
        await OfflineSyncService.instance.queueAction(
          OfflineQueuedAction(
            id: 'cancel-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
            type: OfflineActionType.cancelTransaction,
            payload: {'transactionId': transactionId},
            createdAt: DateTime.now(),
            retryCount: 0,
          ),
        );
        return {'queued': true, 'message': 'Cancellation queued for sync.'};
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/transactions/cancel/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await getMyTransactions();
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        error['detail'] ??
            'Failed to cancel transaction: ${response.statusCode}',
      );
    } on SocketException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'cancel-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.cancelTransaction,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Cancellation queued for sync.'};
    } on TimeoutException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'cancel-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.cancelTransaction,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Cancellation queued for sync.'};
    } on http.ClientException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'cancel-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.cancelTransaction,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Cancellation queued for sync.'};
    } catch (e) {
      throw Exception('Cancel transaction error: $e');
    }
  }

  Future<Map<String, dynamic>> completeTransaction(String transactionId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please log in.');
      }

      if (!await OfflineSyncService.instance.hasConnection()) {
        await OfflineSyncService.instance.queueAction(
          OfflineQueuedAction(
            id: 'complete-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
            type: OfflineActionType.completeTransaction,
            payload: {'transactionId': transactionId},
            createdAt: DateTime.now(),
            retryCount: 0,
          ),
        );
        return {'queued': true, 'message': 'Completion queued for sync.'};
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/transactions/complete/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await getMyTransactions();
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        error['detail'] ??
            'Failed to complete transaction: ${response.statusCode}',
      );
    } on SocketException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'complete-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.completeTransaction,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Completion queued for sync.'};
    } on TimeoutException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'complete-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.completeTransaction,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Completion queued for sync.'};
    } on http.ClientException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'complete-$transactionId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.completeTransaction,
          payload: {'transactionId': transactionId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      return {'queued': true, 'message': 'Completion queued for sync.'};
    } catch (e) {
      throw Exception('Complete transaction error: $e');
    }
  }
}
