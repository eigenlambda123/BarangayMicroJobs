import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/job_service.dart';
import '../widgets/job_header_card.dart';
import '../widgets/job_action_buttons.dart';

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
                isLoading: _isLoading,
                onApplyPressed: _applyForJob,
                onDeletePressed: _deleteJob,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
