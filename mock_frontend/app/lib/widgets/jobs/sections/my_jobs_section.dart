import 'package:flutter/material.dart';

import '../../../screens/job_details_screen.dart';
import '../../../utils/history_helpers.dart';
import '../../common/compact_pagination_controls.dart';
import '../../common/empty_state.dart';
import '../cards/posting_card.dart';
import '../../transactions/transaction_history_card.dart';

class MyJobsSection extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  final List<Map<String, dynamic>> transactions;
  final VoidCallback? onTransactionUpdated;
  final VoidCallback? onGoToMarketplace;

  const MyJobsSection({
    super.key,
    required this.jobs,
    required this.transactions,
    this.onTransactionUpdated,
    this.onGoToMarketplace,
  });

  @override
  State<MyJobsSection> createState() => _MyJobsSectionState();
}

class _MyJobsSectionState extends State<MyJobsSection> {
  static const int itemsPerPage = 5;
  int _currentPage = 1;

  int get _totalPages => (widget.jobs.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedJobs {
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return widget.jobs.sublist(
      startIndex,
      endIndex > widget.jobs.length ? widget.jobs.length : endIndex,
    );
  }

  String _effectiveStatusForJob(Map<String, dynamic> job) {
    final jobId = job['id']?.toString();
    if (jobId == null || jobId.isEmpty) {
      return (job['status'] ?? 'open').toString();
    }

    final linkedTransactions = widget.transactions.where((transaction) {
      final linkedJob = transaction['job'];
      return linkedJob is Map && linkedJob['id']?.toString() == jobId;
    }).toList();

    final completedTransaction = linkedTransactions.any(
      (transaction) =>
          (transaction['status'] ?? '').toString().toLowerCase() == 'completed',
    );
    if (completedTransaction) {
      return 'completed';
    }

    final hiredTransaction = linkedTransactions.any(
      (transaction) =>
          (transaction['status'] ?? '').toString().toLowerCase() == 'hired',
    );
    if (hiredTransaction) {
      return 'assigned';
    }

    return (job['status'] ?? 'open').toString();
  }

  @override
  void didUpdateWidget(covariant MyJobsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage > _totalPages && _totalPages > 0) {
      _currentPage = _totalPages;
    }
    if (widget.jobs.isEmpty) {
      _currentPage = 1;
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filter for active transactions (where user is requester and status is not completed)
    final activeTransactions = widget.transactions.where((transaction) {
      return (transaction['is_requester'] == true) &&
          ((transaction['status'] ?? '').toString().toLowerCase() !=
              'completed');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== MAIN TITLE =====
        Text(
          'My Jobs',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),

        // ===== POSTED JOBS SECTION =====
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Posted Jobs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${widget.jobs.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Jobs you have already published in the barangay marketplace.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 14),
                if (_paginatedJobs.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No jobs posted yet',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < _paginatedJobs.length; i++) ...[
                        PostingCard(
                          title: _paginatedJobs[i]['title'] ?? 'Unknown Job',
                          price: '₱${_paginatedJobs[i]['salary'] ?? '0'}',
                          location:
                              _paginatedJobs[i]['location'] ??
                              'Unknown Location',
                          applicants:
                              _paginatedJobs[i]['applicants_count'] ?? 0,
                          status: _effectiveStatusForJob(_paginatedJobs[i]),
                          date: _paginatedJobs[i]['last_modified'] != null
                              ? formatDate(_paginatedJobs[i]['last_modified'])
                              : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return JobDetailsScreen(
                                    jobTitle:
                                        _paginatedJobs[i]['title'] ?? 'Job',
                                    price:
                                        '₱${_paginatedJobs[i]['salary'] ?? '0'}',
                                    location:
                                        _paginatedJobs[i]['location'] ??
                                        'Unknown',
                                    jobId: _paginatedJobs[i]['id'] ?? '',
                                    posterId:
                                        _paginatedJobs[i]['poster_id'] ?? '',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        if (i < _paginatedJobs.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                if (widget.jobs.isNotEmpty && _totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 380) {
                          return CompactPaginationControls(
                            currentPage: _currentPage,
                            totalPages: _totalPages,
                            activeColor: colorScheme.primary,
                            onPageChanged: (page) =>
                                setState(() => _currentPage = page),
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              child: OutlinedButton.icon(
                                onPressed: _currentPage > 1
                                    ? _goToPreviousPage
                                    : null,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Page $_currentPage of $_totalPages',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: FilledButton.tonalIcon(
                                onPressed: _currentPage < _totalPages
                                    ? _goToNextPage
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Next'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ===== ACTIVE TRANSACTIONS SECTION =====
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Active Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${activeTransactions.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Jobs you have hired workers for and are currently in progress.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 14),
                if (activeTransactions.isEmpty)
                  const EmptyState(
                    title: 'No active transactions',
                    subtitle:
                        'Transactions in progress will appear here once a worker is hired.',
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < activeTransactions.length; i++) ...[
                        TransactionHistoryCard(
                          transaction: activeTransactions[i],
                          onTransactionUpdated: widget.onTransactionUpdated,
                          onGoToMarketplace: widget.onGoToMarketplace,
                        ),
                        if (i < activeTransactions.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
