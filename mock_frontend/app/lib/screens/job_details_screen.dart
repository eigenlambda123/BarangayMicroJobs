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

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadJobDetails();
    _loadPoster();
    _checkApplicationStatus();
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
      final applicants = await TransactionService().getApplicants(widget.jobId);
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

  Widget _buildApplicantsSection() {
    if (_currentUserId != widget.posterId) {
      return const SizedBox.shrink();
    }

    final isJobOpen = (_jobData?['status'] ?? 'open') == 'open';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applications (${_applicants.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoadingApplicants)
              const Center(child: CircularProgressIndicator())
            else if (_applicants.isEmpty)
              const Text('No applications yet.')
            else
              ..._applicants.map((applicant) {
                final status = (applicant['status'] ?? 'applied').toString();
                final canHire = isJobOpen && status == 'applied';
                final transactionId = applicant['transaction_id']?.toString();
                final isHiring =
                    transactionId != null &&
                    _hiringTransactionId == transactionId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant['name'] ?? 'Unknown Applicant',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rating: ${(applicant['rating'] ?? 0).toString()} (${applicant['review_count'] ?? 0} reviews)',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${applicant['phone_number'] ?? '-'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == 'hired'
                                  ? Colors.blue
                                  : (status == 'completed'
                                        ? Colors.green
                                        : Colors.orange),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: canHire && !isHiring
                                ? () => _hireApplicant(applicant)
                                : null,
                            child: isHiring
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Hire'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final isJobPoster = _currentUserId == widget.posterId;
    final isJobOpen = (_jobData?['status'] ?? 'open') == 'open';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 32),
              JobActionButtons(
                isJobPoster: isJobPoster,
                hasApplied: _hasApplied,
                isJobOpen: isJobOpen,
                isLoading: _isLoading,
                onApplyPressed: _applyForJob,
                onDeletePressed: _deleteJob,
              ),
              const SizedBox(height: 16),
              _buildApplicantsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
