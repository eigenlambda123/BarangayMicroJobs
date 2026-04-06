import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../widgets/transactions/transaction_details_content.dart';
import '../widgets/transactions/rating_dialog.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/common/error_state.dart';

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
    final transaction = _transactionData!;
    final isRequester = transaction['is_requester'] as bool;

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
              // Show rating dialog if this is the job poster (requester)
              if (isRequester) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _showRatingDialog();
                  }
                });
              }
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    final transaction = _transactionData!;
    final providerName = transaction['provider']['name'] ?? 'Provider';

    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        providerName: providerName,
        transactionId: widget.transactionId,
        onRatingSubmitted: _loadTransactionDetails,
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
        body: const LoadingState(),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: ErrorState(
          errorMessage: _errorMessage!,
          onRetry: _loadTransactionDetails,
        ),
      );
    }

    final transaction = _transactionData!;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: TransactionDetailsContent(
        transaction: transaction,
        onCompletePressed: _showCompleteConfirmation,
        onCancelPressed: _showCancelConfirmation,
      ),
    );
  }
}
