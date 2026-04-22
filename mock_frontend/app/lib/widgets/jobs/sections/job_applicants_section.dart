import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../services/transaction_service.dart';
import 'job_applicant_filters_sheet.dart';

class JobApplicantsSection extends StatefulWidget {
  final String? currentUserId;
  final String posterId;
  final String jobId;
  final bool isJobOpen;
  final Future<void> Function() onHireComplete;

  const JobApplicantsSection({
    required this.currentUserId,
    required this.posterId,
    required this.jobId,
    required this.isJobOpen,
    required this.onHireComplete,
    super.key,
  });

  @override
  State<JobApplicantsSection> createState() => _JobApplicantsSectionState();
}

class _JobApplicantsSectionState extends State<JobApplicantsSection> {
  bool _isLoadingApplicants = false;
  String? _hiringTransactionId;
  List<Map<String, dynamic>> _applicants = [];
  final TextEditingController _applicantSearchController =
      TextEditingController();
  final TextEditingController _minRatingController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String _applicantStatusFilter = 'All';

  JobApplicantFilterSelection get _filterSelection =>
      JobApplicantFilterSelection(
        status: _applicantStatusFilter,
        minRating: _minRatingController.text,
        skills: _skillsController.text,
      );

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  @override
  void didUpdateWidget(covariant JobApplicantsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId ||
        oldWidget.currentUserId != widget.currentUserId ||
        oldWidget.posterId != widget.posterId) {
      _loadApplicants();
    }
  }

  @override
  void dispose() {
    _applicantSearchController.dispose();
    _minRatingController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicants() async {
    if (widget.currentUserId != widget.posterId) {
      return;
    }

    if (widget.jobId.isEmpty) {
      return;
    }

    setState(() => _isLoadingApplicants = true);
    try {
      final applicants = await TransactionService().getApplicants(
        widget.jobId,
        query: _applicantSearchController.text,
        status: _applicantStatusFilter == 'All' ? null : _applicantStatusFilter,
        minRating: _minRatingController.text,
        skills: _skillsController.text,
      );
      if (mounted) {
        setState(() {
          _applicants = applicants;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading applicants: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingApplicants = false);
      }
    }
  }

  void _clearApplicantFilters() {
    setState(() {
      _applicantSearchController.clear();
      _minRatingController.clear();
      _skillsController.clear();
      _applicantStatusFilter = 'All';
    });
    _loadApplicants();
  }

  Future<void> _openFilterSheet() async {
    final result = await showJobApplicantFiltersSheet(
      context: context,
      initialSelection: _filterSelection,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _applicantStatusFilter = result.status;
      _minRatingController.text = result.minRating;
      _skillsController.text = result.skills;
    });
    _loadApplicants();
  }

  Future<void> _hireApplicant(Map<String, dynamic> applicant) async {
    final transactionId = applicant['transaction_id']?.toString();
    if (transactionId == null || transactionId.isEmpty) {
      return;
    }

    setState(() {
      _hiringTransactionId = transactionId;
    });

    try {
      await TransactionService().hireProvider(transactionId);
      await widget.onHireComplete();
      await _loadApplicants();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hired ${applicant['name']} successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to hire applicant: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _hiringTransactionId = null;
        });
      }
    }
  }

  Color _applicantStatusColor(String status) {
    switch (status) {
      case 'hired':
        return const Color(0xFF0D5C63);
      case 'completed':
        return const Color(0xFF2A6A31);
      default:
        return const Color(0xFFDB7C26);
    }
  }

  Widget _snapshotChip({
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
    if (widget.currentUserId != widget.posterId) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final hasActiveFilters = _filterSelection.hasFilters;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applications (${_applicants.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: _isLoadingApplicants ? null : _loadApplicants,
                icon: Icon(Icons.refresh, color: colorScheme.primary),
                tooltip: 'Refresh applications',
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Review applicants and hire directly from this list.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6A7278)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _applicantSearchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _loadApplicants(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search applicant name or phone',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.tune),
                    label: const Text('Filters'),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_filterSelection.activeFilterCount}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 8),
            Text(
              '${_filterSelection.activeFilterCount} filters active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_isLoadingApplicants)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_applicants.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.hourglass_empty_rounded, color: Color(0xFF7A7F83)),
                  SizedBox(height: 8),
                  Text(
                    'No applications yet',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Applications will appear here once people apply.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF6A7278)),
                  ),
                ],
              ),
            )
          else
            ..._applicants.map((applicant) {
              final status = (applicant['status'] ?? 'applied').toString();
              final canHire = widget.isJobOpen && status == 'applied';
              final transactionId = applicant['transaction_id']?.toString();
              final isHiring =
                  transactionId != null &&
                  _hiringTransactionId == transactionId;
              final statusColor = _applicantStatusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF7),
                  border: Border.all(color: const Color(0xFFDAD2C7)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: statusColor.withValues(alpha: 0.16),
                          child: Text(
                            (applicant['name'] ?? '?')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            applicant['name'] ?? 'Unknown Applicant',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _snapshotChip(
                          icon: Icons.star_outline,
                          label:
                              '${(applicant['rating'] ?? 0).toString()} (${applicant['review_count'] ?? 0} reviews)',
                          color: const Color(0xFFDB7C26),
                        ),
                        _snapshotChip(
                          icon: Icons.phone_outlined,
                          label: applicant['phone_number'] ?? '-',
                          color: const Color(0xFF0D5C63),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: canHire && !isHiring
                            ? () => _hireApplicant(applicant)
                            : null,
                        icon: isHiring
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.person_add_alt_1),
                        label: Text(isHiring ? 'Hiring...' : 'Hire Applicant'),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
