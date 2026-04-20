import 'package:flutter/material.dart';
import '../../transactions/transaction_history_card.dart';

class AcceptedJobsSection extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onCompletePressed;

  const AcceptedJobsSection({
    super.key,
    required this.transactions,
    required this.onCompletePressed,
  });

  @override
  State<AcceptedJobsSection> createState() => _AcceptedJobsSectionState();
}

class _AcceptedJobsSectionState extends State<AcceptedJobsSection> {
  static const int itemsPerPage = 3;
  int _currentPage = 1;

  late List<Map<String, dynamic>> _appliedJobs;

  @override
  void initState() {
    super.initState();
    _syncTransactions();
  }

  @override
  void didUpdateWidget(covariant AcceptedJobsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _syncTransactions();
      if (_currentPage > _totalPages && _totalPages > 0) {
        _currentPage = _totalPages;
      }
    }
  }

  void _syncTransactions() {
    _appliedJobs = widget.transactions
        .where((t) => !(t['is_requester'] as bool))
        .toList();
  }

  int get _totalPages => (_appliedJobs.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedJobs {
    if (_appliedJobs.isEmpty) return [];
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return _appliedJobs.sublist(
      startIndex,
      endIndex > _appliedJobs.length ? _appliedJobs.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Jobs I\'ve Applied To',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_appliedJobs.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_appliedJobs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 42,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'No job applications yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Browse available jobs and apply to start earning.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.66),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          ..._paginatedJobs.map((transaction) {
            final status = transaction['status'];
            final providerCompleted =
                transaction['provider_completed'] as bool? ?? false;
            final canComplete = status == 'hired' && !providerCompleted;

            return TransactionHistoryCard(
              transaction: transaction,
              onCompletePressed: canComplete
                  ? () => widget.onCompletePressed(transaction['id'])
                  : null,
              onCancelPressed:
                  null, // Cancel handled in transaction details screen
            );
          }),
          // Pagination Controls
          if (_appliedJobs.isNotEmpty && _totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous',
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(_totalPages, (index) {
                    final pageNum = index + 1;
                    final isActive = pageNum == _currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _currentPage = pageNum),
                        child: Container(
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
