import 'package:flutter/material.dart';

class CompactPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final Color? activeColor;

  const CompactPaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.activeColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = activeColor ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
          ),
          const SizedBox(width: 8),
          ...List.generate(totalPages, (index) {
            final pageNum = index + 1;
            final isActive = pageNum == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onPageChanged(pageNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor
                        : accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next',
          ),
        ],
      ),
    );
  }
}
