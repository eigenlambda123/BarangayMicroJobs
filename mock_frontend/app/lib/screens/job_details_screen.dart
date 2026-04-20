import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/job_service.dart';
import '../widgets/jobs/cards/job_header_card.dart';
import '../widgets/jobs/actions/job_action_buttons.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobTitle;
  final String price;
  final String location;
  final String jobId;
  final String posterId;

  const JobDetailsScreen({
    required this.jobTitle,
    required this.price,
    required this.location,
    required this.jobId,
    required this.posterId,
    super.key,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  String? _currentUserId;
  bool _isLoading = false;
  Map<String, dynamic>? _jobData;
  Map<String, dynamic>? _posterData;
  bool _hasApplied = false;
  bool _isLoadingApplicants = false;
  String? _hiringTransactionId;
  List<Map<String, dynamic>> _applicants = [];
  final TextEditingController _applicantSearchController =
      TextEditingController();
  final TextEditingController _minRatingController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String _applicantStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadJobDetails();
    _loadPoster();
    _checkApplicationStatus();
  }

  @override
  void dispose() {
    _applicantSearchController.dispose();
    _minRatingController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService().getCurrentUser();
      setState(() {
        _currentUserId = user['id'];
      });
      await _loadApplicants();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading current user: $e');
      }
    }
  }

  Future<void> _loadJobDetails() async {
    try {
      final job = await JobService().getJobById(widget.jobId);
      setState(() {
        _jobData = job;
      });
      await _loadApplicants();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading job details: $e');
      }
    }
  }

  Future<void> _loadPoster() async {
    try {
      final poster = await AuthService().getUserById(widget.posterId);
      setState(() {
        _posterData = poster;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading poster: $e');
      }
    }
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final transactions = await TransactionService().getMyTransactions();
      final hasApplied = transactions.any(
        (transaction) =>
            transaction['job']['id'] == widget.jobId &&
            !transaction['is_requester'],
      ); // If not requester, then provider (applied)
      setState(() {
        _hasApplied = hasApplied;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error checking application status: $e');
      }
    }
  }

  Future<void> _loadApplicants() async {
    if (_currentUserId != widget.posterId) {
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
      await _loadJobDetails();
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

  Widget _buildJobSnapshot({
    required bool isJobPoster,
    required bool isJobOpen,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _snapshotChip(
            icon: Icons.person_outline,
            label: isJobPoster ? 'You posted this job' : 'You can apply now',
            color: colorScheme.primary,
          ),
          _snapshotChip(
            icon: Icons.work_outline,
            label: isJobOpen ? 'Status: Open' : 'Status: Closed',
            color: isJobOpen
                ? const Color(0xFF2A6A31)
                : const Color(0xFF7A7F83),
          ),
          _snapshotChip(
            icon: Icons.group_outlined,
            label: '${_applicants.length} applicants',
            color: const Color(0xFFDB7C26),
          ),
        ],
      ),
    );
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

  Widget _buildActionPanel({
    required bool isJobPoster,
    required bool isJobOpen,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isJobPoster ? 'Management Action' : 'Application Action',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          JobActionButtons(
            isJobPoster: isJobPoster,
            hasApplied: _hasApplied,
            isJobOpen: isJobOpen,
            isLoading: _isLoading,
            onApplyPressed: _applyForJob,
            onDeletePressed: _deleteJob,
            onEditPressed: _editJob,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsSection() {
    if (_currentUserId != widget.posterId) {
      return const SizedBox.shrink();
    }

    final isJobOpen = (_jobData?['status'] ?? 'open') == 'open';
    final colorScheme = Theme.of(context).colorScheme;

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
          TextField(
            controller: _applicantSearchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _loadApplicants(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search applicant name or phone',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _applicantStatusFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All statuses')),
                    DropdownMenuItem(value: 'applied', child: Text('Applied')),
                    DropdownMenuItem(value: 'hired', child: Text('Hired')),
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
                    setState(() => _applicantStatusFilter = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minRatingController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Min Rating',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skillsController,
            decoration: const InputDecoration(
              hintText: 'Skills (comma-separated)',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearApplicantFilters,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loadApplicants,
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
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
              final canHire = isJobOpen && status == 'applied';
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

  Future<void> _applyForJob() async {
    setState(() => _isLoading = true);
    try {
      await TransactionService().applyForJob(widget.jobId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Applied successfully!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Assuming we add a deleteJob method to JobService
        await JobService().deleteJob(widget.jobId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job deleted successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting job: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _editJob() {
    // Show a simple snackbar indicating edit functionality is available in transaction details
    // The actual edit is implemented in JobDetailsCard within transaction details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Edit job details in transaction or view full details below',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isJobPoster = _currentUserId == widget.posterId;
    final isJobOpen = (_jobData?['status'] ?? 'open') == 'open';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Container(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JobHeaderCard(
                  jobTitle: widget.jobTitle,
                  price: widget.price,
                  location: widget.location,
                  jobData: _jobData,
                  posterData: _posterData,
                ),
                const SizedBox(height: 14),
                _buildJobSnapshot(
                  isJobPoster: isJobPoster,
                  isJobOpen: isJobOpen,
                ),
                const SizedBox(height: 14),
                _buildActionPanel(
                  isJobPoster: isJobPoster,
                  isJobOpen: isJobOpen,
                ),
                const SizedBox(height: 14),
                _buildApplicantsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
