import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/job_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobTitle;
  final String price;
  final String zone;
  final String jobId;
  final String posterId;

  const JobDetailsScreen({
    required this.jobTitle,
    required this.price,
    required this.zone,
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
      final hasApplied = transactions.any((transaction) =>
          transaction['job']['id'] == widget.jobId &&
          !transaction['is_requester']); // If not requester, then provider (applied)
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
              _buildJobHeader(),
              const SizedBox(height: 32),
              if (!isJobPoster)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _hasApplied ? null : (_isLoading ? null : _applyForJob),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(_hasApplied ? 'Applied' : (_isLoading ? 'Applying...' : 'Apply for Job')),
                    style: _hasApplied
                        ? ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          )
                        : null,
                  ),
                ),
              if (isJobPoster)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _deleteJob,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Job'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.jobTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (_jobData?['image'] != null && _jobData!['image'].isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_jobData!['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Posted by: ${_posterData?['full_name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (_jobData?['last_modified'] != null)
              Text(
                'Posted on: ${_formatDate(_jobData!['last_modified'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zone',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.zone,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OPEN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}
