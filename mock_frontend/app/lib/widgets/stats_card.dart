import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const StatsCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final jobsDone = userData?['jobs_done'] ?? 0;
    final jobsPosted = userData?['jobs_posted'] ?? 0;
    final totalEarned = (userData?['total_earned'] ?? 0.0).toStringAsFixed(2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(jobsDone.toString(), 'Jobs Done'),
            _buildStatItem(jobsPosted.toString(), 'Posted'),
            _buildStatItem('₱$totalEarned', 'Earned'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
