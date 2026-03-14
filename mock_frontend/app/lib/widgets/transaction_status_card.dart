import 'package:flutter/material.dart';
import '../utils/transaction_helpers.dart';

/// Card widget for displaying transaction status and timeline
class TransactionStatusCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionStatusCard({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatusItem(
              status: 'Applied',
              timestamp: transaction['accepted_at'],
              isCompleted: true,
            ),
            const SizedBox(height: 8),
            StatusItem(
              status: 'Hired',
              timestamp: transaction['accepted_at'],
              isCompleted: transaction['status'] != 'applied',
            ),
            const SizedBox(height: 8),
            StatusItem(
              status: 'Completed',
              timestamp: transaction['completed_at'],
              isCompleted: transaction['status'] == 'completed',
            ),
            // Show completion confirmation status
            if (TransactionHelpers.canShowCompletionStatus(transaction)) ...[
              const SizedBox(height: 8),
              CompletionStatusIndicator(transaction: transaction),
            ],
          ],
        ),
      ),
    );
  }
}
