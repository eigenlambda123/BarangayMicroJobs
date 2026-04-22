import 'package:flutter/material.dart';
import '../jobs/cards/job_details_card.dart';
import 'transaction_status_card.dart';
import 'transaction_parties_card.dart';
import 'transaction_action_buttons.dart';

class TransactionDetailsContent extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onCompletePressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onJobUpdated;

  const TransactionDetailsContent({
    super.key,
    required this.transaction,
    required this.onCompletePressed,
    required this.onCancelPressed,
    required this.onJobUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final job = transaction['job'];
    final provider = transaction['provider'];
    final requester = transaction['requester'];
    final isRequester = transaction['is_requester'] as bool;
    final status = (transaction['status'] ?? 'unknown').toString();
    final statusLabel = status.toUpperCase();
    final canEditJob =
        isRequester &&
        status == 'applied' &&
        (job['status'] ?? '').toString().toLowerCase() == 'open';

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF2A6A31);
        break;
      case 'hired':
        statusColor = const Color(0xFF0D5C63);
        break;
      case 'applied':
        statusColor = const Color(0xFFDB7C26);
        break;
      case 'canceled':
        statusColor = const Color(0xFFB42318);
        break;
      default:
        statusColor = const Color(0xFF6A7278);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _summaryChip(
                  icon: Icons.info_outline,
                  label: statusLabel,
                  color: statusColor,
                ),
                _summaryChip(
                  icon: Icons.swap_horiz,
                  label: isRequester ? 'Requester view' : 'Provider view',
                  color: colorScheme.primary,
                ),
                _summaryChip(
                  icon: Icons.payments_outlined,
                  label: '₱${job['salary'] ?? 0}',
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Job Details Card
          JobDetailsCard(
            job: job,
            onJobUpdated: onJobUpdated,
            canEdit: canEditJob,
          ),

          const SizedBox(height: 14),

          // Status and Timeline Card
          TransactionStatusCard(transaction: transaction),

          const SizedBox(height: 14),

          // Parties Involved Card
          TransactionPartiesCard(requester: requester, provider: provider),

          const SizedBox(height: 18),

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

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
