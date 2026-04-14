import 'package:flutter/material.dart';
import '../../utils/transaction_helpers.dart';

/// Card widget for displaying transaction status and timeline
class TransactionStatusCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionStatusCard({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, size: 18),
              SizedBox(width: 8),
              Text(
                'Status & Timeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusItem(
            status: 'Applied',
            timestamp: transaction['accepted_at'],
            isCompleted: true,
          ),
          const SizedBox(height: 10),
          StatusItem(
            status: 'Hired',
            timestamp: transaction['accepted_at'],
            isCompleted: transaction['status'] != 'applied',
          ),
          const SizedBox(height: 10),
          StatusItem(
            status: 'Completed',
            timestamp: transaction['completed_at'],
            isCompleted: transaction['status'] == 'completed',
          ),
          // Show completion confirmation status
          if (TransactionHelpers.canShowCompletionStatus(transaction)) ...[
            const SizedBox(height: 10),
            CompletionStatusIndicator(transaction: transaction),
          ],
        ],
      ),
    );
  }
}
