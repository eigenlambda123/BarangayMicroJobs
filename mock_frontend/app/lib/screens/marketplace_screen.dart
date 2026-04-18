import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/jobs/headers/marketplace_header.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/jobs/sections/my_jobs_section.dart';
import '../widgets/jobs/sections/available_jobs_section.dart';
import '../widgets/jobs/actions/post_job_overlay.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  bool _showPostJobModal = false;
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _userTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadJobs();
    _loadUserTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh transactions when returning to this screen
    _loadUserTransactions();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await AuthService().getUserId();
      if (mounted) {
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load current user: $e');
      }
    }
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await JobService().getAllJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load jobs: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserTransactions() async {
    try {
      final transactions = await TransactionService().getMyTransactions();
      if (mounted) {
        setState(() {
          _userTransactions = transactions;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load user transactions: $e');
      }
      // Don't set error state for transactions, as it's not critical for the main functionality
    }
  }

  List<Map<String, dynamic>> get _myJobs =>
      _jobs.where((job) => job['poster_id'] == _currentUserId).toList();

  List<Map<String, dynamic>> get _availableJobs {
    // Get job IDs that the user has already applied for
    final appliedJobIds = _userTransactions
        .where((transaction) => !(transaction['is_requester'] as bool))
        .map((transaction) => transaction['job']['id'])
        .toSet();

    return _jobs.where((job) {
      final jobStatus = (job['status'] ?? '').toString().toLowerCase();
      return job['poster_id'] != _currentUserId && // Not posted by current user
          !appliedJobIds.contains(job['id']) && // Not already applied for
          jobStatus == 'open'; // Hide jobs that already have a hired worker
    }) // Not already applied for
    .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() => _showPostJobModal = true);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: const Text(
              'Post Job',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            tooltip: 'Post a Job',
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MarketplaceHeader(),
                  const SizedBox(height: 20),
                  _buildActivePostingsSection(context),
                ],
              ),
            ),
          ),
        ),
        // Post Job Modal Overlay
        if (_showPostJobModal)
          PostJobOverlay(
            onClose: () {
              setState(() => _showPostJobModal = false);
            },
            onSubmit: () {
              setState(() => _showPostJobModal = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job posted successfully!')),
              );
              _loadJobs();
            },
          ),
      ],
    );
  }

  Widget _buildActivePostingsSection(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_errorMessage != null) {
      return ErrorState(errorMessage: _errorMessage!, onRetry: _loadJobs);
    }

    if (_jobs.isEmpty) {
      return const EmptyState(
        title: 'No jobs available',
        subtitle: 'Check back later for new opportunities',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Posted Jobs Section
        if (_myJobs.isNotEmpty) MyJobsSection(jobs: _myJobs),

        // Available Jobs Section (All other jobs)
        if (_availableJobs.isNotEmpty)
          AvailableJobsSection(jobs: _availableJobs, onRefresh: _loadJobs)
        else if (_myJobs.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: EmptyState(
              title: 'No other jobs available to apply for',
              subtitle: '',
            ),
          ),
      ],
    );
  }
}
