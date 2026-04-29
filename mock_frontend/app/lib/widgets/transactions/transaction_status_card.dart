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
    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;

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
          if (TransactionHelpers.canShowCancellationStatus(transaction)) ...[
            const SizedBox(height: 10),
            CancellationStatusIndicator(transaction: transaction),
          ],
          if (TransactionHelpers.canShowCompletionStatus(transaction) &&
              transaction['status'] == 'hired' &&
              !(transaction['requester_canceled'] as bool? ?? false) &&
              !(transaction['provider_canceled'] as bool? ?? false)) ...[
            const SizedBox(height: 10),
            CompletionStatusIndicator(transaction: transaction),
          ],
          if (transaction['status'] == 'canceled') ...[
            const SizedBox(height: 10),
            StatusItem(
              status: StatusDisplay.label('canceled'),
              timestamp: requesterCanceled && providerCanceled
                  ? 'Confirmed by both parties'
                  : 'Cancellation pending confirmation',
              isCompleted: true,
              accentColor: const Color(0xFFB42318),
            ),
          ],
        ],
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  final String status;
  final dynamic timestamp;
  final bool isCompleted;
  final Color? accentColor;

  const StatusItem({
    super.key,
    required this.status,
    required this.timestamp,
    required this.isCompleted,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        accentColor ??
        (isCompleted ? colorScheme.primary : colorScheme.outline);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? accent : Colors.transparent,
            border: Border.all(color: accent, width: 2),
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 9, color: colorScheme.onPrimary)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic value) {
    if (value == null) return 'Pending';

    try {
      final date = value is DateTime ? value : DateTime.parse(value.toString());
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.month}/${date.day}/${date.year} • $hour:$minute';
    } catch (_) {
      return value.toString();
    }
  }
}

class CancellationStatusIndicator extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const CancellationStatusIndicator({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;
    final message = requesterCanceled && providerCanceled
        ? 'Cancellation confirmed by both parties'
        : 'Cancellation pending confirmation from the other party';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB42318).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB42318).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, size: 18, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionStatusIndicator extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const CompletionStatusIndicator({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = (transaction['status'] ?? '').toString().toLowerCase();
    final message = status == 'hired'
        ? 'Waiting for completion confirmation'
        : 'Job completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
