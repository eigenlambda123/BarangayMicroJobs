import 'package:flutter/material.dart';
import 'job_details_card.dart';
import 'transaction_status_card.dart';
import 'transaction_parties_card.dart';
import 'transaction_action_buttons.dart';

class TransactionDetailsContent extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onCompletePressed;
  final VoidCallback onCancelPressed;

  const TransactionDetailsContent({
    super.key,
    required this.transaction,
    required this.onCompletePressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final job = transaction['job'];
    final provider = transaction['provider'];
    final requester = transaction['requester'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Details Card
          JobDetailsCard(job: job),

          const SizedBox(height: 16),

          // Status and Timeline Card
          TransactionStatusCard(transaction: transaction),

          const SizedBox(height: 16),

          // Parties Involved Card
          TransactionPartiesCard(requester: requester, provider: provider),

          const SizedBox(height: 24),

          // Action Buttons - Only show if not completed
          if (transaction['status'] != 'completed') ...[
            TransactionActionButtons(
              transaction: transaction,
              onCompletePressed: onCompletePressed,
              onCancelPressed: onCancelPressed,
            ),
          ],
        ],
      ),
    );
  }
}
