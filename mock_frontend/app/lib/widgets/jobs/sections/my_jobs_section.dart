import 'package:flutter/material.dart';
import '../cards/posting_card.dart';
import '../../../screens/job_details_screen.dart';
import '../../../utils/history_helpers.dart';

class MyJobsSection extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;

  const MyJobsSection({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Posted Jobs (${jobs.length})',
          style: Theme.of(context).textTheme.titleLarge,
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
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
}
