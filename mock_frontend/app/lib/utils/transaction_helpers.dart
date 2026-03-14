import 'package:flutter/material.dart';

/// Utility functions for transaction-related operations
class TransactionHelpers {
  /// Format a date-time string for display
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  /// Get the appropriate completion button text based on transaction state
  static String getCompletionButtonText(Map<String, dynamic> transaction) {
    final isRequester = transaction['is_requester'] as bool;
    final requesterCompleted =
        transaction['requester_completed'] as bool? ?? false;
    final providerCompleted =
        transaction['provider_completed'] as bool? ?? false;

    final userCompleted = isRequester ? requesterCompleted : providerCompleted;
    final otherCompleted = isRequester ? providerCompleted : requesterCompleted;

    if (userCompleted && otherCompleted) {
      return 'Job Completed';
    } else if (userCompleted) {
      return 'Waiting for Other Party';
    } else if (otherCompleted) {
      return 'Confirm Completion';
    } else {
      return 'Mark Job as Completed';
    }
  }

  /// Check if transaction can show completion actions
  static bool canShowCompletionActions(Map<String, dynamic> transaction) {
    return transaction['status'] == 'hired' ||
        transaction['status'] == 'applied';
  }

  /// Check if transaction can show completion status
  static bool canShowCompletionStatus(Map<String, dynamic> transaction) {
    return transaction['status'] == 'hired' ||
        transaction['status'] == 'applied';
  }
}

/// Widget for building status timeline items
class StatusItem extends StatelessWidget {
  final String status;
  final String? timestamp;
  final bool isCompleted;

  const StatusItem({
    required this.status,
    this.timestamp,
    required this.isCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted ? Colors.black : Colors.grey,
            ),
          ),
        ),
        if (timestamp != null)
          Text(
            TransactionHelpers.formatDateTime(timestamp!),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}

/// Widget for building completion status indicators
class CompletionStatusIndicator extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const CompletionStatusIndicator({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isRequester = transaction['is_requester'] as bool;
    final requesterCompleted =
        transaction['requester_completed'] as bool? ?? false;
    final providerCompleted =
        transaction['provider_completed'] as bool? ?? false;

    String statusText;
    Color statusColor;

    if (requesterCompleted && providerCompleted) {
      statusText = 'Both parties have confirmed completion';
      statusColor = Colors.green;
    } else if (requesterCompleted || providerCompleted) {
      if ((isRequester && requesterCompleted) ||
          (!isRequester && providerCompleted)) {
        statusText =
            'You have confirmed completion. Waiting for the other party.';
        statusColor = Colors.orange;
      } else {
        statusText =
            'The other party has confirmed completion. Please confirm to complete the job.';
        statusColor = Colors.blue;
      }
    } else {
      statusText = 'Waiting for completion confirmation from both parties';
      statusColor = Colors.grey;
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              color: statusColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
