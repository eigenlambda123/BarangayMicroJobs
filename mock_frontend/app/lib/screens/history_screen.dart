import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/jobs/sections/posted_jobs_section.dart';
import '../widgets/jobs/sections/accepted_jobs_section.dart';
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

  Future<void> _completeTransaction(String transactionId) async {
    try {
      await TransactionService().completeTransaction(transactionId);
      // Reload transactions to reflect the change
      await _loadTransactions();
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

  void _showCompleteConfirmation(String transactionId) {
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
              _completeTransaction(transactionId);
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _handleComplete(String transactionId) =>
      _showCompleteConfirmation(transactionId);

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
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
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
            const Expanded(child: Center(child: Text('No transactions found')))
          else
            Expanded(
              child: ListView(
                children: [
                  PostedJobsSection(
                    transactions: _transactions,
                    onCompletePressed: _handleComplete,
                  ),
                  const SizedBox(height: 24),
                  AcceptedJobsSection(
                    transactions: _transactions,
                    onCompletePressed: _handleComplete,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
