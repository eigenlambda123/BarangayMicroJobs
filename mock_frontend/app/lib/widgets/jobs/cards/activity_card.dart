import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String price;
  final String date;
  final String status;
  final Color statusColor;
  final String worker;
  final VoidCallback? onRatePressed;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onTap;
  final VoidCallback? onCompletePressed;

  const ActivityCard({
    required this.title,
    required this.price,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.worker,
    this.onRatePressed,
    this.onCancelPressed,
    this.onTap,
    this.onCompletePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 13,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.62,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                worker,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3BAF4A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.56),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (onCompletePressed != null ||
                  onCancelPressed != null ||
                  onRatePressed != null)
                const SizedBox(height: 10),
              if (onCompletePressed != null ||
                  onCancelPressed != null ||
                  onRatePressed != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (onCompletePressed != null)
                      FilledButton.tonal(
                        onPressed: onCompletePressed,
                        child: const Text('Mark Complete'),
                      ),
                    if (onCancelPressed != null)
                      OutlinedButton(
                        onPressed: onCancelPressed,
                        child: const Text('Cancel'),
                      ),
                    if (onRatePressed != null)
                      FilledButton(
                        onPressed: onRatePressed,
                        child: const Text('Rate Service'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
