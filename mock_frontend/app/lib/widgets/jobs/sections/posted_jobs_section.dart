import 'package:flutter/material.dart';
import '../../../widgets/transactions/transaction_history_card.dart';

class PostedJobsSection extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onCompletePressed;

  const PostedJobsSection({
    super.key,
    required this.transactions,
    required this.onCompletePressed,
  });

  @override
  State<PostedJobsSection> createState() => _PostedJobsSectionState();
}

class _PostedJobsSectionState extends State<PostedJobsSection> {
  static const int itemsPerPage = 3;
  int _currentPage = 1;

  late List<Map<String, dynamic>> _hiredJobs;

  @override
  void initState() {
    super.initState();
    _syncTransactions();
  }

  @override
  void didUpdateWidget(covariant PostedJobsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _syncTransactions();
      if (_currentPage > _totalPages && _totalPages > 0) {
        _currentPage = _totalPages;
      }
    }
  }

  void _syncTransactions() {
    _hiredJobs = widget.transactions
        .where(
          (t) =>
              (t['is_requester'] as bool) &&
              ((t['status'] == 'hired') || (t['status'] == 'completed')),
        )
        .toList();
  }

  int get _totalPages => (_hiredJobs.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedJobs {
    if (_hiredJobs.isEmpty) return [];
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return _hiredJobs.sublist(
      startIndex,
      endIndex > _hiredJobs.length ? _hiredJobs.length : endIndex,
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
            const Icon(Icons.storefront_outlined, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Jobs I\'ve Hired For',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_hiredJobs.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_hiredJobs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDAD2C7)),
            ),
            child: Column(
              children: [
                Icon(Icons.work_outline, size: 42, color: Colors.grey[500]),
                const SizedBox(height: 10),
                const Text(
                  'No hired jobs yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  'Hire an applicant from your posted jobs to track it here.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
            final requesterCompleted =
                transaction['requester_completed'] as bool? ?? false;
            final canComplete =
                status == 'hired' && providerCompleted && !requesterCompleted;

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
          if (_hiredJobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFDAD2C7)),
                    ),
                    child: Text(
                      'Page $_currentPage of $_totalPages',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
