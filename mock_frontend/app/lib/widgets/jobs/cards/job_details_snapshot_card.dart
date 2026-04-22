import 'package:flutter/material.dart';
import '../../../utils/status_display.dart';

class JobDetailsSnapshotCard extends StatelessWidget {
  final bool isJobPoster;
  final String jobStatus;
  final int? applicantsCount;

  const JobDetailsSnapshotCard({
    required this.isJobPoster,
    required this.jobStatus,
    required this.applicantsCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _snapshotChip(
            icon: Icons.person_outline,
            label: isJobPoster ? 'You posted this job' : 'You can apply now',
            color: colorScheme.primary,
          ),
          _snapshotChip(
            icon: Icons.work_outline,
            label: 'Status: ${StatusDisplay.label(jobStatus)}',
            color: StatusDisplay.color(jobStatus, colorScheme),
          ),
          if (applicantsCount != null)
            _snapshotChip(
              icon: Icons.group_outlined,
              label: '$applicantsCount applicants',
              color: const Color(0xFFDB7C26),
            ),
        ],
      ),
    );
  }

  Widget _snapshotChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
