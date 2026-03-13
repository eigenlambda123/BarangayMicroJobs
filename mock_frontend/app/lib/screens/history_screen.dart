import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/activity_card.dart';
import '../services/transaction_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await TransactionService().getMyTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load transactions: ${e.toString()}';
          _isLoading = false;
        });
      }
      if (kDebugMode) {
        print('Error loading transactions: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Activity History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTransactions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_transactions.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No transactions found'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  final job = transaction['job'];
                  final provider = transaction['provider'];
                  final requester = transaction['requester'];
                  final isRequester = transaction['is_requester'] as bool;

                  // Determine worker name based on role
                  final workerName = isRequester ? provider['name'] : requester['name'];

                  // Format date
                  final acceptedAt = DateTime.parse(transaction['accepted_at']);
                  final dateString = _formatDate(acceptedAt);

                  // Determine status and color
                  final status = transaction['status'];
                  Color statusColor;
                  String statusText;
                  switch (status) {
                    case 'completed':
                      statusColor = Colors.green;
                      statusText = 'COMPLETED';
                      break;
                    case 'hired':
                      statusColor = Colors.blue;
                      statusText = 'IN PROGRESS';
                      break;
                    case 'applied':
                      statusColor = Colors.orange;
                      statusText = 'APPLIED';
                      break;
                    case 'canceled':
                      statusColor = Colors.red;
                      statusText = 'CANCELED';
                      break;
                    default:
                      statusColor = Colors.grey;
                      statusText = status.toUpperCase();
                  }

                  return Column(
                    children: [
                      ActivityCard(
                        title: job['title'],
                        price: '₱${job['salary']}',
                        date: dateString,
                        status: statusText,
                        statusColor: statusColor,
                        worker: workerName,
                        onRatePressed: status == 'completed' ? () {
                          // TODO: Implement rating
                        } : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
