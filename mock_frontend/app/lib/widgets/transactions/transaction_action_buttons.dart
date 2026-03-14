import 'package:flutter/material.dart';
import '../../utils/transaction_helpers.dart';

/// Widget for transaction action buttons (complete and cancel)
class TransactionActionButtons extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onCompletePressed;
  final VoidCallback onCancelPressed;

  const TransactionActionButtons({
    required this.transaction,
    required this.onCompletePressed,
    required this.onCancelPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (TransactionHelpers.canShowCompletionActions(transaction))
            ElevatedButton.icon(
              onPressed: onCompletePressed,
              icon: const Icon(Icons.check_circle),
              label: Text(
                TransactionHelpers.getCompletionButtonText(transaction),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onCancelPressed,
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Cancel Transaction'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}
