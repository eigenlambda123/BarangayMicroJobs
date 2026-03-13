import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/posting_card.dart';
import '../widgets/post_job_modal.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import 'job_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  bool _showPostJobModal = false;
  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadJobs();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await AuthService().getUserId();
      if (mounted) {
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load current user: $e');
      }
    }
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await JobService().getAllJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load jobs: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _myJobs =>
      _jobs.where((job) => job['poster_id'] == _currentUserId).toList();

  List<Map<String, dynamic>> get _availableJobs =>
      _jobs.where((job) => job['poster_id'] != _currentUserId).toList();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 32),
                _buildActivePostingsSection(context),
              ],
            ),
          ),
        ),
        // Post Job Modal Overlay
        if (_showPostJobModal)
          GestureDetector(
            onTap: () {
              setState(() => _showPostJobModal = false);
            },
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: PostJobModal(
                  onClose: () {
                    setState(() => _showPostJobModal = false);
                  },
                  onSubmit: () {
                    setState(() => _showPostJobModal = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job posted successfully!')),
                    );
                    _loadJobs();
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '● ONLINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() => _showPostJobModal = true);
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('POST JOB'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildActivePostingsSection(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading jobs...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadJobs, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              Text(
                'No jobs available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new opportunities',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Posted Jobs Section
        if (_myJobs.isNotEmpty) ...[
          Text(
            'My Posted Jobs (${_myJobs.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ..._myJobs.map((job) {
            return Column(
              children: [
                PostingCard(
                  title: job['title'] ?? 'Unknown Job',
                  price: '₱${job['salary'] ?? '0'}',
                  zone: job['location'] ?? 'Unknown Location',
                  applicants: job['applicants_count'] ?? 0,
                  status: 'OPEN',
                  date: job['last_modified'] != null
                      ? _formatDate(job['last_modified'])
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return JobDetailsScreen(
                            jobTitle: job['title'] ?? 'Job',
                            price: '₱${job['salary'] ?? '0'}',
                            zone: job['location'] ?? 'Unknown',
                            jobId: job['id'] ?? '',
                            posterId: job['poster_id'] ?? '',
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
          const SizedBox(height: 24),
        ],

        // Available Jobs Section (All other jobs)
        if (_availableJobs.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Jobs (${_availableJobs.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              GestureDetector(
                onTap: _loadJobs,
                child: Icon(Icons.refresh, color: Colors.blue.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._availableJobs.map((job) {
            final posterName = job['poster'] != null
                ? job['poster']['full_name']
                : 'Unknown User';
            return Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostingCard(
                      title: job['title'] ?? 'Unknown Job',
                      price: '₱${job['salary'] ?? '0'}',
                      zone: job['location'] ?? 'Unknown Location',
                      applicants: job['applicants_count'] ?? 0,
                      status: 'OPEN',
                      date: job['last_modified'] != null
                          ? _formatDate(job['last_modified'])
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return JobDetailsScreen(
                                jobTitle: job['title'] ?? 'Job',
                                price: '₱${job['salary'] ?? '0'}',
                                zone: job['location'] ?? 'Unknown',
                                jobId: job['id'] ?? '',
                                posterId: job['poster_id'] ?? '',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ] else if (_myJobs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No other jobs available to apply for',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
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
