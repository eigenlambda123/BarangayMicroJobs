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

  late List<Map<String, dynamic>> _postedJobs;

  @override
  void initState() {
    super.initState();
    _postedJobs = widget.transactions
        .where((t) => t['is_requester'] as bool)
        .toList();
  }

  int get _totalPages => (_postedJobs.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedJobs {
    if (_postedJobs.isEmpty) return [];
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return _postedJobs.sublist(
      startIndex,
      endIndex > _postedJobs.length ? _postedJobs.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Posted Jobs (${_postedJobs.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_postedJobs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16, width: double.infinity),
                  const Text(
                    'No jobs posted yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your skills and post a job to get started',
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
          if (_postedJobs.isNotEmpty)
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
