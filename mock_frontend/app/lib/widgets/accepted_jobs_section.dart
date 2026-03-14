import 'package:flutter/material.dart';
import 'transaction_history_card.dart';

class AcceptedJobsSection extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onCancelPressed;
  final Function(String) onCompletePressed;

  const AcceptedJobsSection({
    super.key,
    required this.transactions,
    required this.onCancelPressed,
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
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No jobs accepted yet'),
            ),
          )
        else
          ...acceptedJobs.map((transaction) {
            final status = transaction['status'];
            final canCancel = status == 'applied' || status == 'hired';
            final canComplete = status == 'hired';

            return TransactionHistoryCard(
              transaction: transaction,
              onCompletePressed: canComplete
                  ? () => onCompletePressed(transaction['id'])
                  : null,
              onCancelPressed: canCancel
                  ? () => onCancelPressed(transaction['id'])
                  : null,
            );
          }),
      ],
    );
  }
}
