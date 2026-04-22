import 'package:flutter/material.dart';

import 'marketplace_filter_sheet.dart';

class MarketplaceFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final MarketplaceFilterSelection filters;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onFilterPressed;
  final VoidCallback onClearPressed;

  const MarketplaceFilterBar({
    required this.searchController,
    required this.filters,
    required this.onSearchSubmitted,
    required this.onFilterPressed,
    required this.onClearPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSearchSubmitted,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search jobs',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onFilterPressed,
                    icon: const Icon(Icons.tune),
                    label: const Text('Filter'),
                  ),
                  if (filters.hasFilters)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${filters.activeFilterCount}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (filters.hasFilters) const SizedBox(height: 8),
          if (filters.hasFilters)
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (filters.location != 'All')
                        Chip(label: Text(filters.location)),
                      if (filters.status != 'All')
                        Chip(label: Text('Status: ${filters.status}')),
                      if (filters.minSalary.trim().isNotEmpty)
                        Chip(label: Text('Min: ${filters.minSalary.trim()}')),
                      if (filters.maxSalary.trim().isNotEmpty)
                        Chip(label: Text('Max: ${filters.maxSalary.trim()}')),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onClearPressed,
                  child: const Text('Clear'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
