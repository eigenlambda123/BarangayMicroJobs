import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

enum OfflineActionType {
  createJob,
  updateJob,
  deleteJob,
  applyForJob,
  hireProvider,
  cancelTransaction,
  completeTransaction,
}

class OfflineQueuedAction {
  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  OfflineQueuedAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };

  factory OfflineQueuedAction.fromJson(Map<String, dynamic> json) {
    return OfflineQueuedAction(
      id: json['id']?.toString() ?? '',
      type: OfflineActionType.values.firstWhere(
        (actionType) => actionType.name == json['type'],
        orElse: () => OfflineActionType.applyForJob,
      ),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );
  }

  OfflineQueuedAction copyWith({int? retryCount}) {
    return OfflineQueuedAction(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class OfflineSyncService {
  OfflineSyncService._();

  static final OfflineSyncService instance = OfflineSyncService._();
  static const String _pendingActionsKey = 'offline_pending_actions';
  static const String _cachedJobsKey = 'offline_cached_jobs';
  static const String _cachedTransactionsKey = 'offline_cached_transactions';
  static const String _idAliasesKey = 'offline_id_aliases';

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  Future<void> initialize() async {
    if (_connectivitySubscription != null) {
      return;
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (_hasConnection(results)) {
        syncPendingActions();
      }
    });

    await syncPendingActions();
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<List<Map<String, dynamic>>> getCachedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_cachedJobsKey) ?? <String>[];
    return rawItems
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  Future<void> cacheJobs(List<Map<String, dynamic>> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _cachedJobsKey,
      jobs.map((job) => jsonEncode(job)).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getCachedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_cachedTransactionsKey) ?? <String>[];
    return rawItems
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  Future<void> cacheTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _cachedTransactionsKey,
      transactions.map((transaction) => jsonEncode(transaction)).toList(),
    );
  }

  Future<void> upsertCachedJob(Map<String, dynamic> job) async {
    final jobs = await getCachedJobs();
    final jobId = job['id']?.toString();
    final index = jobs.indexWhere(
      (cachedJob) => cachedJob['id']?.toString() == jobId,
    );
    if (index == -1) {
      jobs.insert(0, job);
    } else {
      jobs[index] = job;
    }
    await cacheJobs(jobs);
  }

  Future<void> removeCachedJob(String jobId) async {
    final jobs = await getCachedJobs();
    jobs.removeWhere((job) => job['id']?.toString() == jobId);
    await cacheJobs(jobs);
  }

  Future<void> upsertCachedTransaction(Map<String, dynamic> transaction) async {
    final transactions = await getCachedTransactions();
    final transactionId = transaction['id']?.toString();
    final index = transactions.indexWhere(
      (cachedTransaction) =>
          cachedTransaction['id']?.toString() == transactionId,
    );
    if (index == -1) {
      transactions.insert(0, transaction);
    } else {
      transactions[index] = transaction;
    }
    await cacheTransactions(transactions);
  }

  Future<void> removeCachedTransaction(String transactionId) async {
    final transactions = await getCachedTransactions();
    transactions.removeWhere(
      (transaction) => transaction['id']?.toString() == transactionId,
    );
    await cacheTransactions(transactions);
  }

  Future<void> setAlias({
    required String entityType,
    required String localId,
    required String serverId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawAliases = prefs.getString(_idAliasesKey);
    final aliases = rawAliases == null
        ? <String, dynamic>{}
        : jsonDecode(rawAliases) as Map<String, dynamic>;
    aliases['$entityType:$localId'] = serverId;
    await prefs.setString(_idAliasesKey, jsonEncode(aliases));
  }

  Future<String?> resolveAlias({
    required String entityType,
    required String localId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawAliases = prefs.getString(_idAliasesKey);
    if (rawAliases == null || rawAliases.isEmpty) {
      return null;
    }

    final aliases = jsonDecode(rawAliases) as Map<String, dynamic>;
    return aliases['$entityType:$localId']?.toString();
  }

  Future<void> queueAction(OfflineQueuedAction action) async {
    final actions = await getPendingActions();
    actions.add(action);
    await _savePendingActions(actions);
  }

  Future<List<OfflineQueuedAction>> getPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    final rawActions = prefs.getStringList(_pendingActionsKey) ?? <String>[];
    return rawActions
        .map(
          (item) => OfflineQueuedAction.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> _savePendingActions(List<OfflineQueuedAction> actions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _pendingActionsKey,
      actions.map((action) => jsonEncode(action.toJson())).toList(),
    );
  }

  Future<void> syncPendingActions() async {
    if (_isSyncing) {
      return;
    }

    if (!await hasConnection()) {
      return;
    }

    _isSyncing = true;
    try {
      final pendingActions = await getPendingActions();
      if (pendingActions.isEmpty) {
        return;
      }

      final remainingActions = <OfflineQueuedAction>[];
      for (final action in pendingActions) {
        if (!await hasConnection()) {
          remainingActions.add(action);
          remainingActions.addAll(
            pendingActions.skipWhile((item) => item.id != action.id).skip(1),
          );
          break;
        }

        try {
          final success = await _processAction(action);
          if (!success) {
            remainingActions.add(
              action.copyWith(retryCount: action.retryCount + 1),
            );
          }
        } on SocketException catch (_) {
          remainingActions.add(
            action.copyWith(retryCount: action.retryCount + 1),
          );
          break;
        } on TimeoutException catch (_) {
          remainingActions.add(
            action.copyWith(retryCount: action.retryCount + 1),
          );
          break;
        } catch (_) {
          remainingActions.add(
            action.copyWith(retryCount: action.retryCount + 1),
          );
        }
      }

      await _savePendingActions(remainingActions);
      await refreshCachedServerData();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> refreshCachedServerData() async {
    if (!await hasConnection()) {
      return;
    }

    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final jobsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/jobs/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (jobsResponse.statusCode == 200) {
        final List<dynamic> jobs =
            jsonDecode(jobsResponse.body) as List<dynamic>;
        final serverJobs = jobs.cast<Map<String, dynamic>>();
        final cachedJobs = await getCachedJobs();
        final mergedJobs = [...serverJobs];

        for (final pendingJob in cachedJobs) {
          final syncStatus = (pendingJob['sync_status'] ?? '').toString();
          if (syncStatus == 'pending_delete') {
            continue;
          }

          final pendingId = pendingJob['id']?.toString() ?? '';
          final aliasId = await resolveAlias(
            entityType: 'job',
            localId: pendingId,
          );
          final serverMatchId = aliasId ?? pendingId;
          final existingIndex = mergedJobs.indexWhere(
            (job) => job['id']?.toString() == serverMatchId,
          );

          if (existingIndex == -1) {
            mergedJobs.add(pendingJob);
          } else if (syncStatus == 'pending') {
            mergedJobs[existingIndex] = pendingJob;
          }
        }

        await cacheJobs(mergedJobs);
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed refreshing cached jobs: $e');
      }
    }

    try {
      final transactionsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transactions/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (transactionsResponse.statusCode == 200) {
        final decoded =
            jsonDecode(transactionsResponse.body) as Map<String, dynamic>;
        final serverTransactions =
            (decoded['transactions'] as List<dynamic>? ?? <dynamic>[])
                .cast<Map<String, dynamic>>();
        final cachedTransactions = await getCachedTransactions();
        final mergedTransactions = [...serverTransactions];

        for (final pendingTransaction in cachedTransactions) {
          final syncStatus = (pendingTransaction['sync_status'] ?? '')
              .toString();
          final pendingId = pendingTransaction['id']?.toString() ?? '';
          final aliasId = await resolveAlias(
            entityType: 'transaction',
            localId: pendingId,
          );
          final serverMatchId = aliasId ?? pendingId;
          final existingIndex = mergedTransactions.indexWhere(
            (transaction) => transaction['id']?.toString() == serverMatchId,
          );

          if (syncStatus == 'pending_delete') {
            continue;
          }

          if (existingIndex == -1) {
            mergedTransactions.add(pendingTransaction);
          } else if (syncStatus == 'pending') {
            mergedTransactions[existingIndex] = pendingTransaction;
          }
        }

        await cacheTransactions(mergedTransactions);
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed refreshing cached transactions: $e');
      }
    }
  }

  Future<bool> _processAction(OfflineQueuedAction action) async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    switch (action.type) {
      case OfflineActionType.createJob:
        return _syncCreateJob(action, token);
      case OfflineActionType.updateJob:
        return _syncUpdateJob(action, token);
      case OfflineActionType.deleteJob:
        return _syncDeleteJob(action, token);
      case OfflineActionType.applyForJob:
        return _syncApplyForJob(action, token);
      case OfflineActionType.hireProvider:
        return _syncHireProvider(action, token);
      case OfflineActionType.cancelTransaction:
        return _syncCancelTransaction(action, token);
      case OfflineActionType.completeTransaction:
        return _syncCompleteTransaction(action, token);
    }
  }

  Future<bool> _syncCreateJob(OfflineQueuedAction action, String token) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/jobs/create-with-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = action.payload['title']?.toString() ?? '';
    request.fields['description'] =
        action.payload['description']?.toString() ?? '';
    request.fields['location'] = action.payload['location']?.toString() ?? '';
    request.fields['salary'] = action.payload['salary']?.toString() ?? '';

    final imageBase64 = action.payload['imageBase64']?.toString();
    final imageName =
        action.payload['imageName']?.toString() ?? 'offline-job-image.jpg';
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          base64Decode(imageBase64),
          filename: imageName,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final localId = action.payload['localId']?.toString();
      final serverId = decoded['job_id']?.toString();
      if (localId != null && serverId != null) {
        await setAlias(entityType: 'job', localId: localId, serverId: serverId);
      }
      return true;
    }

    return false;
  }

  Future<bool> _syncUpdateJob(OfflineQueuedAction action, String token) async {
    final jobId = await _resolveEntityId(
      'job',
      action.payload['jobId']?.toString() ?? '',
    );
    if (jobId == null || jobId.isEmpty) {
      return false;
    }

    final body = <String, dynamic>{
      if (action.payload['title'] != null) 'title': action.payload['title'],
      if (action.payload['description'] != null)
        'description': action.payload['description'],
      if (action.payload['location'] != null)
        'location': action.payload['location'],
      if (action.payload['salary'] != null) 'salary': action.payload['salary'],
      if (action.payload['image'] != null) 'image': action.payload['image'],
    };

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  Future<bool> _syncDeleteJob(OfflineQueuedAction action, String token) async {
    final jobId = await _resolveEntityId(
      'job',
      action.payload['jobId']?.toString() ?? '',
    );
    if (jobId == null || jobId.isEmpty) {
      return false;
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> _syncApplyForJob(
    OfflineQueuedAction action,
    String token,
  ) async {
    final jobId = await _resolveEntityId(
      'job',
      action.payload['jobId']?.toString() ?? '',
    );
    if (jobId == null || jobId.isEmpty) {
      return false;
    }

    final localId = action.payload['localId']?.toString() ?? '';
    final currentUserId = await AuthService().getUserId();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/transactions/apply/$jobId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final transactionsResponse = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/transactions/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (transactionsResponse.statusCode == 200 &&
        localId.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      final decoded =
          jsonDecode(transactionsResponse.body) as Map<String, dynamic>;
      final transactions =
          (decoded['transactions'] as List<dynamic>? ?? <dynamic>[])
              .cast<Map<String, dynamic>>();
      final matchingTransaction = transactions
          .cast<Map<String, dynamic>?>()
          .firstWhere((transaction) {
            if (transaction == null) return false;
            final job = transaction['job'];
            final provider = transaction['provider'];
            return transaction['is_requester'] == false &&
                job is Map &&
                job['id']?.toString() == jobId &&
                provider is Map &&
                provider['id']?.toString() == currentUserId;
          }, orElse: () => null);

      if (matchingTransaction != null) {
        await removeCachedTransaction(localId);
        await upsertCachedTransaction(matchingTransaction);
        await setAlias(
          entityType: 'transaction',
          localId: localId,
          serverId: matchingTransaction['id']?.toString() ?? localId,
        );
      }
    }
    return true;
  }

  Future<bool> _syncHireProvider(
    OfflineQueuedAction action,
    String token,
  ) async {
    final transactionId = await _resolveEntityId(
      'transaction',
      action.payload['transactionId']?.toString() ?? '',
    );
    if (transactionId == null || transactionId.isEmpty) {
      return false;
    }

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/transactions/hire/$transactionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> _syncCancelTransaction(
    OfflineQueuedAction action,
    String token,
  ) async {
    final transactionId = await _resolveEntityId(
      'transaction',
      action.payload['transactionId']?.toString() ?? '',
    );
    if (transactionId == null || transactionId.isEmpty) {
      return false;
    }

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/transactions/cancel/$transactionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> _syncCompleteTransaction(
    OfflineQueuedAction action,
    String token,
  ) async {
    final transactionId = await _resolveEntityId(
      'transaction',
      action.payload['transactionId']?.toString() ?? '',
    );
    if (transactionId == null || transactionId.isEmpty) {
      return false;
    }

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/transactions/complete/$transactionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<String?> _resolveEntityId(String entityType, String id) async {
    final alias = await resolveAlias(entityType: entityType, localId: id);
    return alias ?? id;
  }
}
