import 'package:flutter/material.dart';
import '../../utils/transaction_helpers.dart';
import '../../utils/status_display.dart';

/// Card widget for displaying transaction status and timeline
class TransactionStatusCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionStatusCard({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Status & Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusItem(
            status: StatusDisplay.label('applied'),
            timestamp: transaction['accepted_at'],
            isCompleted: true,
          ),
          const SizedBox(height: 10),
          StatusItem(
            status: StatusDisplay.label('assigned'),
            timestamp: transaction['accepted_at'],
            isCompleted: transaction['status'] != 'applied',
          ),
          const SizedBox(height: 10),
          StatusItem(
            status: StatusDisplay.label('completed'),
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
