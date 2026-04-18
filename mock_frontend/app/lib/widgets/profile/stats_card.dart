import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const StatsCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final jobsDone = userData?['jobs_done'] ?? 0;
    final jobsPosted = userData?['jobs_posted'] ?? 0;
    final totalEarned = (userData?['total_earned'] ?? 0.0).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Activity',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.task_alt_outlined,
                  value: jobsDone.toString(),
                  label: 'Jobs Done',
                  color: const Color(0xFF2A6A31),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.campaign_outlined,
                  value: jobsPosted.toString(),
                  label: 'Posted',
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.payments_outlined,
                  value: '₱$totalEarned',
                  label: 'Earned',
                  color: const Color(0xFFDB7C26),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF60686E)),
          ),
        ],
      ),
    );
  }
}
