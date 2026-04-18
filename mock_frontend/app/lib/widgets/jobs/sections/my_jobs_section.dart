import 'package:flutter/material.dart';

import '../../../screens/job_details_screen.dart';
import '../../../utils/history_helpers.dart';
import '../cards/posting_card.dart';

class MyJobsSection extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;

  const MyJobsSection({super.key, required this.jobs});

  @override
  State<MyJobsSection> createState() => _MyJobsSectionState();
}

class _MyJobsSectionState extends State<MyJobsSection> {
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

  @override
  void didUpdateWidget(covariant MyJobsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage > _totalPages && _totalPages > 0) {
      _currentPage = _totalPages;
    }
    if (widget.jobs.isEmpty) {
      _currentPage = 1;
    }
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
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'My Posted Jobs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${widget.jobs.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Jobs you have already published in the barangay marketplace.',
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: colorScheme.onSurface.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(height: 14),
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
        if (widget.jobs.isNotEmpty && _totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Page $_currentPage of $_totalPages',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
