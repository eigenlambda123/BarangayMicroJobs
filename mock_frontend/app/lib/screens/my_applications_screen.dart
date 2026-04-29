import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/transactions/transaction_history_card.dart';
import '../widgets/marketplace/marketplace_background_orb.dart';
import '../widgets/marketplace/marketplace_section_shell.dart';

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
    final ongoingApps = _applications.where((t) {
      final st = (t['status'] ?? '').toString().toLowerCase();
      return !(st == 'completed' || st == 'cancelled' || st == 'canceled');
    }).toList();

    final completedApps = _applications.where((t) {
      final st = (t['status'] ?? '').toString().toLowerCase();
      return (st == 'completed' || st == 'cancelled' || st == 'canceled');
    }).toList();

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
                      // ===== MAIN TITLE =====
                      Text(
                        'My Applications',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),

                      // ===== APPLICATIONS SECTION =====
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ongoing and Completed sections
                          if (_isLoading)
                            const LoadingState()
                          else if (_errorMessage != null)
                            ErrorState(
                              errorMessage: _errorMessage!,
                              onRetry: _loadMyApplications,
                            )
                          else
                            Column(
                              children: [
                                // Ongoing card
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Ongoing',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge,
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                '${ongoingApps.length}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Active applications you have applied to or are currently engaged with.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.35,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.62),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        if (ongoingApps.isEmpty)
                                          const EmptyState(
                                            title: 'No ongoing applications',
                                            subtitle:
                                                'You have no active applications at the moment',
                                          )
                                        else
                                          Column(
                                            children: [
                                              for (
                                                int i = 0;
                                                i < ongoingApps.length;
                                                i++
                                              ) ...[
                                                TransactionHistoryCard(
                                                  transaction: ongoingApps[i],
                                                  onCompletePressed: null,
                                                  onTransactionUpdated:
                                                      _loadMyApplications,
                                                  onGoToMarketplace: null,
                                                ),
                                                if (i < ongoingApps.length - 1)
                                                  const SizedBox(height: 12),
                                              ],
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Completed card
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.secondary.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Completed',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge,
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.secondary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                '${completedApps.length}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.secondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Completed and cancelled applications are listed here for your records.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.35,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.62),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        if (completedApps.isEmpty)
                                          const EmptyState(
                                            title: 'No completed applications',
                                            subtitle:
                                                'Completed or cancelled applications will appear here',
                                          )
                                        else
                                          Column(
                                            children: [
                                              for (
                                                int i = 0;
                                                i < completedApps.length;
                                                i++
                                              ) ...[
                                                TransactionHistoryCard(
                                                  transaction: completedApps[i],
                                                  onCompletePressed: null,
                                                  onTransactionUpdated:
                                                      _loadMyApplications,
                                                  onGoToMarketplace: null,
                                                ),
                                                if (i <
                                                    completedApps.length - 1)
                                                  const SizedBox(height: 12),
                                              ],
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
