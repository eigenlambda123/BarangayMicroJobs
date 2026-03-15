import 'package:flutter/material.dart';
import '../../transactions/transaction_history_card.dart';

class AcceptedJobsSection extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onCompletePressed;

  const AcceptedJobsSection({
    super.key,
    required this.transactions,
    required this.onCompletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final acceptedJobs = transactions
        .where((t) => !(t['is_requester'] as bool))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jobs I\'m Working On (${acceptedJobs.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (acceptedJobs.isEmpty)
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
        else
          ...acceptedJobs.map((transaction) {
            final status = transaction['status'];
            final canComplete = status == 'hired';

            return TransactionHistoryCard(
              transaction: transaction,
              onCompletePressed: canComplete
                  ? () => onCompletePressed(transaction['id'])
                  : null,
              onCancelPressed:
                  null, // Cancel handled in transaction details screen
            );
          }),
      ],
    );
  }
}
