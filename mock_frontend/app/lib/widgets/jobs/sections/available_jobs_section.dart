import 'package:flutter/material.dart';
import '../cards/posting_card.dart';
import '../../../screens/job_details_screen.dart';
import '../../../utils/history_helpers.dart';

class AvailableJobsSection extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  final VoidCallback onRefresh;

  const AvailableJobsSection({
    super.key,
    required this.jobs,
    required this.onRefresh,
  });

  @override
  State<AvailableJobsSection> createState() => _AvailableJobsSectionState();
}

class _AvailableJobsSectionState extends State<AvailableJobsSection> {
  static const int itemsPerPage = 5;
  int _currentPage = 1;

  int get _totalPages => (widget.jobs.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedJobs {
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return widget.jobs.sublist(
      startIndex,
      endIndex > widget.jobs.length ? widget.jobs.length : endIndex,
    );
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Jobs (${widget.jobs.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            GestureDetector(
              onTap: widget.onRefresh,
              child: Icon(Icons.refresh, color: Colors.blue.shade700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._paginatedJobs.map((job) {
          return Column(
            children: [
              PostingCard(
                title: job['title'] ?? 'Unknown Job',
                price: '₱${job['salary'] ?? '0'}',
                location: job['location'] ?? 'Unknown Location',
                applicants: job['applicants_count'] ?? 0,
                status: 'OPEN',
                date: job['last_modified'] != null
                    ? formatDate(job['last_modified'])
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return JobDetailsScreen(
                          jobTitle: job['title'] ?? 'Job',
                          price: '₱${job['salary'] ?? '0'}',
                          location: job['location'] ?? 'Unknown',
                          jobId: job['id'] ?? '',
                          posterId: job['poster_id'] ?? '',
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        // Pagination Controls
        if (widget.jobs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 16),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
