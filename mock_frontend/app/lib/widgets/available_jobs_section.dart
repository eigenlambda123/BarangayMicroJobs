import 'package:flutter/material.dart';
import '../widgets/posting_card.dart';
import '../screens/job_details_screen.dart';
import '../utils/history_helpers.dart';

class AvailableJobsSection extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;
  final VoidCallback onRefresh;

  const AvailableJobsSection({
    super.key,
    required this.jobs,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Jobs (${jobs.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            GestureDetector(
              onTap: onRefresh,
              child: Icon(Icons.refresh, color: Colors.blue.shade700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...jobs.map((job) {
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
      ],
    );
  }
}
