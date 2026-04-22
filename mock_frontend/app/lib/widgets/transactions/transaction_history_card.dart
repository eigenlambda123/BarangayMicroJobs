import 'package:flutter/material.dart';
import '../jobs/cards/activity_card.dart';
import '../common/rating_dialog.dart';
import '../../screens/transaction_details_screen.dart';
import '../../utils/history_helpers.dart';
import '../../utils/status_display.dart';

class TransactionHistoryCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onCompletePressed;
  final VoidCallback? onCancelPressed;

  const TransactionHistoryCard({
    super.key,
    required this.transaction,
    this.onCompletePressed,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final job = transaction['job'];
    final provider = transaction['provider'];
    final requester = transaction['requester'];
    final isRequester = transaction['is_requester'] as bool;

    // Determine worker name based on role
    final workerName = isRequester ? provider['name'] : requester['name'];

    // Format date
    final acceptedAt = DateTime.parse(transaction['accepted_at']);
    final dateString = formatDate(acceptedAt);

    // Determine status and color
    final status = transaction['status'];
    final statusColor = StatusDisplay.color(status, colorScheme);
    final statusText = StatusDisplay.label(status);

    return Column(
      children: [
        ActivityCard(
          title: job['title'],
          price: '₱${job['salary']}',
          date: dateString,
          status: statusText,
          statusColor: statusColor,
          worker: workerName,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailsScreen(transactionId: transaction['id']),
              ),
            );
          },
          onCompletePressed: onCompletePressed,
          onRatePressed: (status == 'completed' && isRequester)
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => RatingDialog(
                      transactionId: transaction['id'],
                      providerName: isRequester
                          ? provider['name']
                          : requester['name'],
                      jobTitle: job['title'],
                    ),
                  );
                }
              : null,
          onCancelPressed: onCancelPressed,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
