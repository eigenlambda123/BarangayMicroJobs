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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Available Jobs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${widget.jobs.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: widget.onRefresh,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.refresh, color: colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _paginatedJobs.length; i++) ...[
          PostingCard(
            title: _paginatedJobs[i]['title'] ?? 'Unknown Job',
            price: '₱${_paginatedJobs[i]['salary'] ?? '0'}',
            location: _paginatedJobs[i]['location'] ?? 'Unknown Location',
            applicants: _paginatedJobs[i]['applicants_count'] ?? 0,
            status: 'OPEN',
            date: _paginatedJobs[i]['last_modified'] != null
                ? formatDate(_paginatedJobs[i]['last_modified'])
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return JobDetailsScreen(
                      jobTitle: _paginatedJobs[i]['title'] ?? 'Job',
                      price: '₱${_paginatedJobs[i]['salary'] ?? '0'}',
                      location: _paginatedJobs[i]['location'] ?? 'Unknown',
                      jobId: _paginatedJobs[i]['id'] ?? '',
                      posterId: _paginatedJobs[i]['poster_id'] ?? '',
                    );
                  },
                ),
              );
            },
          ),
          if (i < _paginatedJobs.length - 1) const SizedBox(height: 12),
        ],
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
