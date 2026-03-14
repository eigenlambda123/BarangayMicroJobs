import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../widgets/job_details_card.dart';
import '../widgets/transaction_status_card.dart';
import '../widgets/transaction_parties_card.dart';
import '../widgets/transaction_action_buttons.dart';
import '../utils/transaction_helpers.dart';

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

  void _showCancelConfirmation() {
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
              _cancelTransaction();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTransaction() async {
    try {
      await TransactionService().cancelTransaction(widget.transactionId);
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
                onCompletePressed: _showCompleteConfirmation,
                onCancelPressed: _showCancelConfirmation,
              ),
            ],
          ],
        ),
      ),
      // Floating Action Button for completion
      floatingActionButton:
          TransactionHelpers.canShowCompletionActions(transaction)
          ? FloatingActionButton.extended(
              onPressed: _showCompleteConfirmation,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.check_circle),
              label: Text(
                TransactionHelpers.getCompletionButtonText(transaction)
                    .replaceAll('Mark Job as ', '')
                    .replaceAll('Waiting for Other Party', 'Waiting...'),
              ),
            )
          : null,
    );
  }
}
