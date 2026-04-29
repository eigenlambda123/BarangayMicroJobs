import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../services/transaction_service.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/jobs/sections/my_jobs_section.dart';
import 'post_job_screen.dart';
import '../widgets/marketplace/marketplace_background_orb.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMyJobsData();
  }

  Future<void> _loadMyJobsData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        AuthService().getUserId(),
        JobService().getAllJobs(),
        TransactionService().getMyTransactions(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUserId = results[0] as String?;
        _jobs = (results[1] as List).cast<Map<String, dynamic>>();
        _transactions = (results[2] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load my jobs data: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load jobs: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshMyJobs() async {
    await _loadMyJobsData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final myJobs = _currentUserId == null
        ? <Map<String, dynamic>>[]
        : _jobs
              .where((job) => job['poster_id']?.toString() == _currentUserId)
              .toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        Positioned(
          top: -64,
          right: -72,
          child: MarketplaceBackgroundOrb(
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: 180,
          left: -90,
          child: MarketplaceBackgroundOrb(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            size: 220,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
              if (result == true && mounted) {
                _refreshMyJobs();
              }
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 6,
            icon: const Icon(Icons.add),
            label: const Text(
              'Post Job',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            tooltip: 'Post a Job',
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _refreshMyJobs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'My Posted Jobs',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _isLoading ? null : _refreshMyJobs,
                            tooltip: 'Refresh my jobs',
                            icon: Icon(
                              Icons.refresh,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage the jobs you have posted and review who has applied.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: colorScheme.onSurface.withValues(alpha: 0.66),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const LoadingState()
                      else if (_errorMessage != null)
                        ErrorState(
                          errorMessage: _errorMessage!,
                          onRetry: _refreshMyJobs,
                        )
                      else if (myJobs.isEmpty)
                        const EmptyState(
                          title: 'No posted jobs yet',
                          subtitle:
                              'Use Post Job to create your first listing.',
                        )
                      else
                        MyJobsSection(
                          jobs: myJobs,
                          transactions: _transactions,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
