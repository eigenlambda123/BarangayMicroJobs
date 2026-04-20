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
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await TransactionService().getMyTransactions(
        query: _searchController.text,
        location: _locationController.text,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
        role: _selectedRole == 'All' ? null : _selectedRole,
      );
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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _selectedStatus = 'All';
      _selectedRole = 'All';
    });
    _loadTransactions();
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

  int get _activeCount =>
      _transactions.where((t) => t['status'] == 'hired').length;

  int get _completedCount =>
      _transactions.where((t) => t['status'] == 'completed').length;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Activity History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _loadTransactions,
                  tooltip: 'Refresh history',
                  icon: Icon(Icons.refresh, color: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                    icon: Icons.list_alt_outlined,
                    label: '${_transactions.length} total',
                    color: colorScheme.primary,
                  ),
                  _summaryChip(
                    icon: Icons.pending_actions_outlined,
                    label: '$_activeCount active',
                    color: const Color(0xFFDB7C26),
                  ),
                  _summaryChip(
                    icon: Icons.check_circle_outline,
                    label: '$_completedCount completed',
                    color: const Color(0xFF2A6A31),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search and filter activity',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadTransactions(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search title, location, or user',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (exact)',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All statuses'),
                            ),
                            DropdownMenuItem(
                              value: 'applied',
                              child: Text('Applied'),
                            ),
                            DropdownMenuItem(
                              value: 'hired',
                              child: Text('Hired'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                            DropdownMenuItem(
                              value: 'canceled',
                              child: Text('Canceled'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedStatus = value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All roles'),
                            ),
                            DropdownMenuItem(
                              value: 'requester',
                              child: Text('Requester'),
                            ),
                            DropdownMenuItem(
                              value: 'provider',
                              child: Text('Provider'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedRole = value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _loadTransactions,
                          icon: const Icon(Icons.filter_alt_outlined),
                          label: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFB42318),
                          size: 44,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _loadTransactions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_transactions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        size: 46,
                        color: Color(0xFF7A7F83),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your accepted and posted job activity will appear here.',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.66),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    PostedJobsSection(
                      transactions: _transactions,
                      onCompletePressed: _handleComplete,
                    ),
                    const SizedBox(height: 22),
                    AcceptedJobsSection(
                      transactions: _transactions,
                      onCompletePressed: _handleComplete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
