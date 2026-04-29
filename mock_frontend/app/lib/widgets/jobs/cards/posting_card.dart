import 'package:flutter/material.dart';
import '../../../utils/status_display.dart';

class PostingCard extends StatelessWidget {
  final String title;
  final String? description;
  final String price;
  final String location;
  final int applicants;
  final String status;
  final String? date;
  final VoidCallback? onTap;

  const PostingCard({
    required this.title,
    this.description,
    required this.price,
    required this.location,
    required this.applicants,
    required this.status,
    this.date,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusLabel = StatusDisplay.label(status);
    final statusColor = _statusColor(status);
    final previewDescription = description?.trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.25,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (previewDescription != null &&
                            previewDescription.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            previewDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.68,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colorScheme.secondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      applicants == 1
                          ? '1 applicant'
                          : '$applicants applicants',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (date != null)
                    Text(
                      date!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF0D5C63);
      case 'assigned':
      case 'hired':
      case 'applied':
        return const Color(0xFFDB7C26);
      case 'completed':
        return const Color(0xFF2A6A31);
      case 'closed':
      case 'canceled':
        return const Color(0xFFB42318);
      default:
        return const Color(0xFF6A7278);
    }
  }
}
