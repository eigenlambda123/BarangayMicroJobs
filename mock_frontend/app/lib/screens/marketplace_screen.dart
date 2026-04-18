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

  Future<void> _refreshMarketplace() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }

    await Future.wait([
      _loadCurrentUser(),
      _loadJobs(),
      _loadUserTransactions(),
    ]);
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
    final colorScheme = Theme.of(context).colorScheme;

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
          child: _GlowOrb(color: colorScheme.primary.withValues(alpha: 0.12)),
        ),
        Positioned(
          bottom: 180,
          left: -90,
          child: _GlowOrb(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            size: 220,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() => _showPostJobModal = true);
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
              onRefresh: _refreshMarketplace,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MarketplaceHeader(),
                      const SizedBox(height: 16),
                      _buildMarketplaceOverview(context),
                      const SizedBox(height: 18),
                      _MarketplaceSectionShell(
                        child: _buildActivePostingsSection(context),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildMarketplaceOverview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final availableCount = _availableJobs.length;
    final myJobsCount = _myJobs.length;
    final totalCount = _jobs.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.space_dashboard_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live marketplace',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track what you posted and what you can apply for right now.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MarketplaceMetricCard(
                  title: 'Total jobs',
                  value: '$totalCount',
                  icon: Icons.view_list_rounded,
                  tint: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MarketplaceMetricCard(
                  title: 'My postings',
                  value: '$myJobsCount',
                  icon: Icons.cases_outlined,
                  tint: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 18,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$availableCount open opportunities nearby',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        if (_availableJobs.isNotEmpty) const SizedBox(height: 20),
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

class _MarketplaceSectionShell extends StatelessWidget {
  const _MarketplaceSectionShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MarketplaceMetricCard extends StatelessWidget {
  const _MarketplaceMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: tint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, this.size = 220});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}
