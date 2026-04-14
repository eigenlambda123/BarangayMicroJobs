import 'package:flutter/material.dart';
import '../cards/posting_card.dart';
import '../../../screens/job_details_screen.dart';
import '../../../utils/history_helpers.dart';

class MyJobsSection extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;

  const MyJobsSection({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
                '${jobs.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < jobs.length; i++) ...[
          PostingCard(
            title: jobs[i]['title'] ?? 'Unknown Job',
            price: '₱${jobs[i]['salary'] ?? '0'}',
            location: jobs[i]['location'] ?? 'Unknown Location',
            applicants: jobs[i]['applicants_count'] ?? 0,
            status: 'OPEN',
            date: jobs[i]['last_modified'] != null
                ? formatDate(jobs[i]['last_modified'])
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return JobDetailsScreen(
                      jobTitle: jobs[i]['title'] ?? 'Job',
                      price: '₱${jobs[i]['salary'] ?? '0'}',
                      location: jobs[i]['location'] ?? 'Unknown',
                      jobId: jobs[i]['id'] ?? '',
                      posterId: jobs[i]['poster_id'] ?? '',
                    );
                  },
                ),
              );
            },
          ),
          if (i < jobs.length - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
