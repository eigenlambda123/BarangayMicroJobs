import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';
import 'offline_sync_service.dart';

class JobService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String location,
    required String salary,
    String? imagePath,
  }) async {
    final token = await AuthService().getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final offlineSyncService = OfflineSyncService.instance;
    final offline = !await offlineSyncService.hasConnection();
    final localId = 'local-job-${DateTime.now().microsecondsSinceEpoch}';

    Future<Map<String, dynamic>> queueJob() async {
      String? imageBase64;
      String? imageName;
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          imageBase64 = base64Encode(await imageFile.readAsBytes());
          imageName = imagePath.split(RegExp(r'[\\/]')).last;
        }
      }

      final payload = <String, dynamic>{
        'localId': localId,
        'title': title,
        'description': description,
        'location': location,
        'salary': salary,
      };
      if (imageBase64 != null) {
        payload['imageBase64'] = imageBase64;
      }
      if (imageName != null) {
        payload['imageName'] = imageName;
      }

      await offlineSyncService.queueAction(
        OfflineQueuedAction(
          id: 'create-job-$localId',
          type: OfflineActionType.createJob,
          payload: payload,
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );

      await offlineSyncService.upsertCachedJob({
        'id': localId,
        'title': title,
        'description': description,
        'location': location,
        'salary': salary,
        'status': 'open',
        'poster_id': await AuthService().getUserId(),
        'applicants_count': 0,
        'last_modified': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      });

      return {
        'job_id': localId,
        'queued': true,
        'message': 'Job saved offline and will sync when you are back online.',
      };
    }

    if (offline) {
      return queueJob();
    }

    try {
      if (kDebugMode) {
        print('DEBUG: Token retrieved: $token');
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
        await getAllJobs();
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }

      final error = jsonDecode(responseBody) as Map<String, dynamic>;
      throw Exception(
        error['detail'] ?? 'Failed to create job: ${response.statusCode}',
      );
    } on SocketException catch (_) {
      return queueJob();
    } on TimeoutException catch (_) {
      return queueJob();
    } on http.ClientException catch (_) {
      return queueJob();
    } catch (e) {
      throw Exception('Job creation error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllJobs({
    String? query,
    String? location,
    String? status,
    String? minSalary,
    String? maxSalary,
    String? skills,
  }) async {
    try {
      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
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
        final serverJobs = jobs.cast<Map<String, dynamic>>();
        final pendingJobs = cachedJobs.where((job) {
          final syncStatus = (job['sync_status'] ?? '').toString();
          return syncStatus.isNotEmpty && syncStatus != 'synced';
        }).toList();

        final mergedJobs = <Map<String, dynamic>>[...serverJobs];
        for (final pendingJob in pendingJobs) {
          final syncStatus = (pendingJob['sync_status'] ?? '').toString();
          if (syncStatus == 'pending_delete') {
            continue;
          }

          final pendingId = pendingJob['id']?.toString() ?? '';
          final aliasId = await OfflineSyncService.instance.resolveAlias(
            entityType: 'job',
            localId: pendingId,
          );
          final resolvedId = aliasId ?? pendingId;
          final hasAlias =
              aliasId != null && aliasId.isNotEmpty && aliasId != pendingId;

          final serverMatchIndex = mergedJobs.indexWhere(
            (serverJob) => serverJob['id']?.toString() == resolvedId,
          );

          if (serverMatchIndex == -1) {
            mergedJobs.add(pendingJob);
            continue;
          }

          if (!hasAlias && syncStatus == 'pending') {
            mergedJobs[serverMatchIndex] = pendingJob;
          }
        }

        await OfflineSyncService.instance.cacheJobs(mergedJobs);
        return mergedJobs;
      }

      throw Exception('Failed to fetch jobs');
    } catch (e) {
      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      if (cachedJobs.isNotEmpty) {
        return cachedJobs;
      }
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
      }

      throw Exception('Failed to fetch job');
    } catch (e) {
      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      final cachedJob = cachedJobs.firstWhere(
        (job) => job['id']?.toString() == jobId,
        orElse: () => <String, dynamic>{},
      );
      if (cachedJob.isNotEmpty) {
        return cachedJob;
      }
      throw Exception('Get job error: $e');
    }
  }

  Future<Map<String, dynamic>> deleteJob(String jobId) async {
    final token = await AuthService().getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    if (!await OfflineSyncService.instance.hasConnection()) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'delete-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.deleteJob,
          payload: {'jobId': jobId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      await OfflineSyncService.instance.upsertCachedJob({
        'id': jobId,
        'sync_status': 'pending_delete',
      });
      return {'queued': true, 'message': 'Job deletion queued for sync.'};
    }

    try {
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

      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      await OfflineSyncService.instance.cacheJobs(
        cachedJobs.where((job) => job['id']?.toString() != jobId).toList(),
      );
      return {'message': 'Job deleted successfully'};
    } on SocketException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'delete-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.deleteJob,
          payload: {'jobId': jobId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      await OfflineSyncService.instance.upsertCachedJob({
        'id': jobId,
        'sync_status': 'pending_delete',
      });
      return {'queued': true, 'message': 'Job deletion queued for sync.'};
    } on TimeoutException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'delete-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.deleteJob,
          payload: {'jobId': jobId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      await OfflineSyncService.instance.upsertCachedJob({
        'id': jobId,
        'sync_status': 'pending_delete',
      });
      return {'queued': true, 'message': 'Job deletion queued for sync.'};
    } on http.ClientException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'delete-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.deleteJob,
          payload: {'jobId': jobId},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      await OfflineSyncService.instance.upsertCachedJob({
        'id': jobId,
        'sync_status': 'pending_delete',
      });
      return {'queued': true, 'message': 'Job deletion queued for sync.'};
    } catch (e) {
      throw Exception('Delete job error: $e');
    }
  }

  Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? location,
    String? salary,
    String? image,
  }) async {
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

    if (!await OfflineSyncService.instance.hasConnection()) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'update-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.updateJob,
          payload: {'jobId': jobId, ...body},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );

      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      final updatedJobs = cachedJobs.map((job) {
        if (job['id']?.toString() != jobId) {
          return job;
        }
        return {...job, ...body, 'sync_status': 'pending'};
      }).toList();
      await OfflineSyncService.instance.cacheJobs(updatedJobs);
      return {'queued': true, 'message': 'Job update queued for sync.'};
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final updatedJob = jsonDecode(response.body) as Map<String, dynamic>;
        await getAllJobs();
        return updatedJob;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(error['detail'] ?? 'Failed to update job');
    } on SocketException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'update-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.updateJob,
          payload: {'jobId': jobId, ...body},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );

      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      final updatedJobs = cachedJobs.map((job) {
        if (job['id']?.toString() != jobId) {
          return job;
        }
        return {...job, ...body, 'sync_status': 'pending'};
      }).toList();
      await OfflineSyncService.instance.cacheJobs(updatedJobs);
      return {'queued': true, 'message': 'Job update queued for sync.'};
    } on TimeoutException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'update-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.updateJob,
          payload: {'jobId': jobId, ...body},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );

      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      final updatedJobs = cachedJobs.map((job) {
        if (job['id']?.toString() != jobId) {
          return job;
        }
        return {...job, ...body, 'sync_status': 'pending'};
      }).toList();
      await OfflineSyncService.instance.cacheJobs(updatedJobs);
      return {'queued': true, 'message': 'Job update queued for sync.'};
    } on http.ClientException catch (_) {
      await OfflineSyncService.instance.queueAction(
        OfflineQueuedAction(
          id: 'update-job-$jobId-${DateTime.now().microsecondsSinceEpoch}',
          type: OfflineActionType.updateJob,
          payload: {'jobId': jobId, ...body},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      );

      final cachedJobs = await OfflineSyncService.instance.getCachedJobs();
      final updatedJobs = cachedJobs.map((job) {
        if (job['id']?.toString() != jobId) {
          return job;
        }
        return {...job, ...body, 'sync_status': 'pending'};
      }).toList();
      await OfflineSyncService.instance.cacheJobs(updatedJobs);
      return {'queued': true, 'message': 'Job update queued for sync.'};
    } catch (e) {
      throw Exception('Update job error: $e');
    }
  }
}
