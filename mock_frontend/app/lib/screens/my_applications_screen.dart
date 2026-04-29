import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/transactions/transaction_history_card.dart';
import '../widgets/marketplace/marketplace_background_orb.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMyApplications();
  }

  Future<void> _loadMyApplications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        AuthService().getUserId(),
        TransactionService().getMyTransactions(role: 'provider'),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUserId = results[0] as String?;
        _applications = (results[1] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load my applications: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load applications: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshMyApplications() async {
    await _loadMyApplications();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
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
          child: const SizedBox.expand(),
        ),
        Positioned(
          top: -64,
          right: -72,
          child: MarketplaceBackgroundOrb(
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: 180,
          left: -90,
          child: MarketplaceBackgroundOrb(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            size: 220,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _refreshMyApplications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'My Applications',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_applications.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track the status of jobs you have applied to.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: colorScheme.onSurface.withValues(alpha: 0.62),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const LoadingState()
                      else if (_errorMessage != null)
                        ErrorState(
                          errorMessage: _errorMessage!,
                          onRetry: _loadMyApplications,
                        )
                      else if (_applications.isEmpty)
                        const EmptyState(
                          title: 'No applications yet',
                          subtitle:
                              'Apply to jobs in the marketplace to see them here',
                        )
                      else
                        Column(
                          children: [
                            for (int i = 0; i < _applications.length; i++) ...[
                              TransactionHistoryCard(
                                transaction: _applications[i],
                                onCompletePressed: null,
                                onTransactionUpdated: _loadMyApplications,
                                onGoToMarketplace: null,
                              ),
                              if (i < _applications.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
