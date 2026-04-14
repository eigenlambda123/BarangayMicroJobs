import 'package:flutter/material.dart';

/// Card widget for displaying job details
class JobDetailsCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsCard({required this.job, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job['title'] ?? 'Untitled Job',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EED6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '₱${job['salary'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2A6A31),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            (job['description'] ?? 'No description available').toString(),
            style: const TextStyle(fontSize: 14, color: Color(0xFF434A4F)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(
                icon: Icons.location_on_outlined,
                label: (job['location'] ?? 'Unknown location').toString(),
              ),
              _metaChip(
                icon: Icons.schedule_outlined,
                label: 'Transaction linked',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 1),
          Icon(icon, size: 13, color: const Color(0xFF6A7278)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5B6368),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
