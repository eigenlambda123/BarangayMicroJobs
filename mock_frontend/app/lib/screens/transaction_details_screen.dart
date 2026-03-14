import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsScreen({required this.transactionId, super.key});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Map<String, dynamic>? _transactionData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    try {
      final transactions = await TransactionService().getMyTransactions();
      Map<String, dynamic>? transaction;
      for (final t in transactions) {
        if (t['id'] == widget.transactionId) {
          transaction = t;
          break;
        }
      }

      if (transaction != null) {
        if (mounted) {
          setState(() {
            _transactionData = transaction;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Transaction not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load transaction details: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsCompleted() async {
    try {
      await TransactionService().completeTransaction(widget.transactionId);
      // Reload transaction details
      await _loadTransactionDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completion marked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as completed: $e')),
        );
      }
    }
  }

  void _showCompleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Job as Completed'),
        content: const Text(
          'Are you sure you want to mark this job as completed? Both parties need to confirm completion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _markAsCompleted();
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Transaction'),
        content: const Text(
          'Are you sure you want to cancel this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelTransaction(transactionId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTransaction(String transactionId) async {
    try {
      await TransactionService().cancelTransaction(transactionId);
      // Reload transaction details
      await _loadTransactionDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel transaction: $e')),
        );
      }
    }
  }

  Widget _buildStatusItem(
    String status,
    String? timestamp, {
    required bool isCompleted,
  }) {
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
            _formatDateTime(timestamp),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildCompletionStatus(Map<String, dynamic> transaction) {
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

  String _getCompletionButtonText(Map<String, dynamic> transaction) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTransactionDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final transaction = _transactionData!;
    final job = transaction['job'];
    final provider = transaction['provider'];
    final requester = transaction['requester'];

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱${job['salary']}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      job['description'] ?? 'No description available',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job['location'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status and Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status & Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusItem(
                      'Applied',
                      transaction['accepted_at'],
                      isCompleted: true,
                    ),
                    _buildStatusItem(
                      'Hired',
                      transaction['accepted_at'],
                      isCompleted: transaction['status'] != 'applied',
                    ),
                    _buildStatusItem(
                      'Completed',
                      transaction['completed_at'],
                      isCompleted: transaction['status'] == 'completed',
                    ),
                    // Show completion confirmation status
                    if (transaction['status'] == 'hired' ||
                        transaction['status'] == 'applied')
                      _buildCompletionStatus(transaction),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Parties Involved Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parties Involved',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Job Poster: ${requester['name']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.work, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Service Provider: ${provider['name']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons - Only show if not completed
            if (transaction['status'] != 'completed') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (transaction['status'] == 'hired' ||
                        transaction['status'] == 'applied')
                      ElevatedButton.icon(
                        onPressed: _showCompleteConfirmation,
                        icon: const Icon(Icons.check_circle),
                        label: Text(_getCompletionButtonText(transaction)),
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
                      onPressed: () =>
                          _showCancelConfirmation(transaction['id']),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
