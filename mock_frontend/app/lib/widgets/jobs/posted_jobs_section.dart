import 'package:flutter/material.dart';
import '../../widgets/transactions/transaction_history_card.dart';

class PostedJobsSection extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onCompletePressed;

  const PostedJobsSection({
    super.key,
    required this.transactions,
    required this.onCompletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final postedJobs = transactions
        .where((t) => t['is_requester'] as bool)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Posted Jobs (${postedJobs.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (postedJobs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No jobs posted yet'),
            ),
          )
        else
          ...postedJobs.map((transaction) {
            final status = transaction['status'];
            final canComplete = status == 'hired';

            return TransactionHistoryCard(
              transaction: transaction,
              onCompletePressed: canComplete
                  ? () => onCompletePressed(transaction['id'])
                  : null,
              onCancelPressed: null, // Cancel handled in transaction details screen
            );
          }),
      ],
    );
  }
}
