import 'package:flutter/material.dart';
import '../../../../utils/history_helpers.dart';

class JobHeaderCard extends StatelessWidget {
  final String jobTitle;
  final String price;
  final String location;
  final Map<String, dynamic>? jobData;
  final Map<String, dynamic>? posterData;

  const JobHeaderCard({
    super.key,
    required this.jobTitle,
    required this.price,
    required this.location,
    this.jobData,
    this.posterData,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final postedBy = posterData?['full_name'] ?? 'Unknown';
    final postedOn = jobData?['last_modified'] != null
        ? formatDate(jobData!['last_modified'])
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jobTitle,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              width: double.infinity,
              color: colorScheme.primary.withValues(alpha: 0.06),
              child:
                  jobData?['image'] != null &&
                      jobData!['image'].toString().trim().isNotEmpty
                  ? Image.network(
                      jobData!['image'].toString(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          _imageFallback(context, colorScheme),
                    )
                  : _imageFallback(context, colorScheme),
            ),
          ),
          if (jobData?['description'] != null &&
              jobData!['description'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              jobData!['description'].toString(),
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colorScheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No description provided for this job yet.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(
                colorScheme: colorScheme,
                icon: Icons.person_outline,
                label: 'Posted by $postedBy',
                color: colorScheme.primary,
              ),
              if (postedOn != null)
                _metaChip(
                  colorScheme: colorScheme,
                  icon: Icons.calendar_today_outlined,
                  label: postedOn,
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _valueBlock(
                colorScheme: colorScheme,
                title: 'Price',
                value: price,
                color: colorScheme.primary,
                icon: Icons.payments_outlined,
              ),
              _valueBlock(
                colorScheme: colorScheme,
                title: 'Location',
                value: location,
                color: colorScheme.secondary,
                icon: Icons.location_on_outlined,
              ),
              _valueBlock(
                colorScheme: colorScheme,
                title: 'Status',
                value: 'OPEN',
                color: colorScheme.primary,
                icon: Icons.work_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
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

  Widget _valueBlock({
    required ColorScheme colorScheme,
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 42,
            color: colorScheme.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 8),
          Text(
            'No job image available',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.56),
            ),
          ),
        ],
      ),
    );
  }
}
