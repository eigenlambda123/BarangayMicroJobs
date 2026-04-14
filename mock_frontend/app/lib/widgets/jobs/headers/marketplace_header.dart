import 'package:flutter/material.dart';

class MarketplaceHeader extends StatelessWidget {
  const MarketplaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F4F4), Color(0xFFF8F4EC)],
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready for today\'s tasks?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Post a quick job or apply to nearby listings.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A7278)),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
