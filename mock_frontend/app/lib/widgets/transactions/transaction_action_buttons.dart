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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (TransactionHelpers.canShowCompletionActions(transaction))
            ElevatedButton.icon(
              onPressed: onCompletePressed,
              icon: const Icon(Icons.check_circle),
              label: Text(
                TransactionHelpers.getCompletionButtonText(transaction),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onCancelPressed,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Transaction'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB42318),
              side: const BorderSide(color: Color(0xFFEF4444)),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
