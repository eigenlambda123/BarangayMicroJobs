import 'package:flutter/material.dart';
import '../widgets/posting_card.dart';
import '../widgets/post_job_modal.dart';
import '../services/job_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadJobs();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Jobs (${_jobs.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            GestureDetector(
              onTap: _loadJobs,
              child: Icon(Icons.refresh, color: Colors.blue.shade700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._jobs.map((job) {
          return Column(
            children: [
              PostingCard(
                title: job['title'] ?? 'Unknown Job',
                price: '₱${job['salary'] ?? '0'}',
                zone: job['location'] ?? 'Unknown Location',
                applicants: 0,
                status: 'OPEN',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => JobDetailsScreen(
                        jobTitle: job['title'] ?? 'Job',
                        price: '₱${job['salary'] ?? '0'}',
                        zone: job['location'] ?? 'Unknown',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ],
    );
  }
}
