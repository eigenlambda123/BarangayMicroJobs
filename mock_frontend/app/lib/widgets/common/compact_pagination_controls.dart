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

  Widget _buildCircleButton({
    required BuildContext context,
    required ColorScheme colorScheme,
    required Color accentColor,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isEnabled
            ? accentColor.withValues(alpha: 0.14)
            : colorScheme.onSurface.withValues(alpha: 0.06),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? accentColor
                  : colorScheme.onSurface.withValues(alpha: 0.32),
            ),
          ),
        ),
      ),
    );
  }

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
          _buildCircleButton(
            context: context,
            colorScheme: colorScheme,
            accentColor: accentColor,
            icon: Icons.chevron_left,
            tooltip: 'Previous',
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
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
                  width: isActive ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor
                        : accentColor.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          _buildCircleButton(
            context: context,
            colorScheme: colorScheme,
            accentColor: accentColor,
            icon: Icons.chevron_right,
            tooltip: 'Next',
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
