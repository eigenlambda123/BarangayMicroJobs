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

  late List<Map<String, dynamic>> _acceptedJobs;

  @override
  void initState() {
    super.initState();
    _acceptedJobs = widget.transactions
        .where((t) => !(t['is_requester'] as bool))
        .toList();
  }

  int get _totalPages => (_acceptedJobs.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedJobs {
    if (_acceptedJobs.isEmpty) return [];
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return _acceptedJobs.sublist(
      startIndex,
      endIndex > _acceptedJobs.length ? _acceptedJobs.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jobs I\'m Working On (${_acceptedJobs.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_acceptedJobs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No jobs accepted yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse available jobs and apply to start working',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else ...[
          ..._paginatedJobs.map((transaction) {
            final status = transaction['status'];
            final canComplete = status == 'hired';

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
          if (_acceptedJobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
