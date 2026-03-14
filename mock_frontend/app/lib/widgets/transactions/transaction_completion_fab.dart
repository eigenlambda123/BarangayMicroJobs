import 'package:flutter/material.dart';
import '../../utils/transaction_helpers.dart';

class TransactionCompletionFab extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onPressed;

  const TransactionCompletionFab({
    super.key,
    required this.transaction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!TransactionHelpers.canShowCompletionActions(transaction)) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.check_circle),
      label: Text(
        TransactionHelpers.getCompletionButtonText(transaction)
            .replaceAll('Mark Job as ', '')
            .replaceAll('Waiting for Other Party', 'Waiting...'),
      ),
    );
  }
}
