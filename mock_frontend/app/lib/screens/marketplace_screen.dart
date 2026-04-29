import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../services/transaction_service.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/jobs/actions/post_job_overlay.dart';
import '../widgets/jobs/sections/available_jobs_section.dart';
import '../widgets/marketplace/marketplace_background_orb.dart';
import '../widgets/marketplace/marketplace_filter_bar.dart';
import '../widgets/marketplace/marketplace_filter_sheet.dart';
import '../widgets/marketplace/marketplace_overview_card.dart';
import '../widgets/marketplace/marketplace_section_shell.dart';

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
  final TextEditingController _searchController = TextEditingController();
  MarketplaceFilterSelection _filters = const MarketplaceFilterSelection();

  @override
  void initState() {
    super.initState();
    _loadMarketplaceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplaceData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        AuthService().getUserId(),
        JobService().getAllJobs(
          query: _searchController.text,
          location: _filters.apiLocation,
          status: _filters.apiStatus,
          minSalary: _filters.minSalary,
          maxSalary: _filters.maxSalary,
        ),
        TransactionService().getMyTransactions(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUserId = results[0] as String?;
        _jobs = (results[1] as List).cast<Map<String, dynamic>>();
        _userTransactions = (results[2] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load marketplace data: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load jobs: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshMarketplace() async {
    await _loadMarketplaceData();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filters = const MarketplaceFilterSelection();
    });
    _loadMarketplaceData();
  }

  Future<void> _showFilterSheet() async {
    final selection = await showMarketplaceFilterSheet(
      context: context,
      initialSelection: _filters,
      locationOptions: marketplaceLocationOptions,
    );

    if (selection == null) {
      return;
    }

    setState(() {
      _filters = selection;
    });
    _loadMarketplaceData();
  }

  List<Map<String, dynamic>> get _otherUsersJobs {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return const [];
    }

    return _jobs
        .where((job) => job['poster_id']?.toString() != currentUserId)
        .toList();
  }

  List<Map<String, dynamic>> get _availableJobs {
    final appliedJobIds = _userTransactions
        .where((transaction) => !(transaction['is_requester'] as bool))
        .map((transaction) => transaction['job']['id'])
        .toSet();

    return _otherUsersJobs.where((job) {
      final jobStatus = (job['status'] ?? '').toString().toLowerCase();
      return !appliedJobIds.contains(job['id']) && jobStatus == 'open';
    }).toList();
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
                      MarketplaceFilterBar(
                        searchController: _searchController,
                        filters: _filters,
                        onFilterPressed: _showFilterSheet,
                        onSearchSubmitted: (_) => _loadMarketplaceData(),
                        onClearPressed: _clearFilters,
                      ),
                      const SizedBox(height: 12),
                      MarketplaceOverviewCard(
                        totalCount: _otherUsersJobs.length,
                        availableCount: _availableJobs.length,
                      ),
                      const SizedBox(height: 18),
                      MarketplaceSectionShell(
                        child: _buildActivePostingsSection(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
              _loadMarketplaceData();
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
      return ErrorState(
        errorMessage: _errorMessage!,
        onRetry: _loadMarketplaceData,
      );
    }

    if (_otherUsersJobs.isEmpty) {
      return const EmptyState(
        title: 'No marketplace jobs yet',
        subtitle: 'Check back later for new opportunities from other users',
      );
    }

    if (_availableJobs.isEmpty) {
      return const EmptyState(
        title: 'No open jobs from other users',
        subtitle: 'Try clearing filters or check back later',
      );
    }

    return AvailableJobsSection(
      jobs: _availableJobs,
      onRefresh: _loadMarketplaceData,
    );
  }
}
