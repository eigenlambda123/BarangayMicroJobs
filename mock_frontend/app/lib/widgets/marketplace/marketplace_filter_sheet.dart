import 'package:flutter/material.dart';

const List<String> marketplaceLocationOptions = [
  'All',
  'Barangay Bocohan',
  'Barangay Dalahican',
  'Barangay Gulang-Gulang',
  'Barangay Ibabang Dupay',
  'Barangay Ilayang Dupay',
  'Barangay Isabang',
  'Barangay Market View',
  'Barangay Mayao Kanluran',
  'Barangay Mayao Castillo',
  'Barangay Mayao Crossing',
  'Barangay Ransohan',
  'Barangay Salinas',
  'Barangay Talao-Talao',
];

MarketplaceFilterSelection get defaultMarketplaceFilterSelection =>
    const MarketplaceFilterSelection();

class MarketplaceFilterSelection {
  final String location;
  final String status;
  final String minSalary;
  final String maxSalary;

  const MarketplaceFilterSelection({
    this.location = 'All',
    this.status = 'All',
    this.minSalary = '',
    this.maxSalary = '',
  });

  MarketplaceFilterSelection copyWith({
    String? location,
    String? status,
    String? minSalary,
    String? maxSalary,
  }) {
    return MarketplaceFilterSelection(
      location: location ?? this.location,
      status: status ?? this.status,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
    );
  }

  String? get apiLocation => location == 'All' ? null : location;

  String? get apiStatus => status == 'All' ? null : status;

  int get activeFilterCount {
    var count = 0;
    if (location != 'All') count++;
    if (status != 'All') count++;
    if (minSalary.trim().isNotEmpty) count++;
    if (maxSalary.trim().isNotEmpty) count++;
    return count;
  }

  bool get hasFilters => activeFilterCount > 0;
}

Future<MarketplaceFilterSelection?> showMarketplaceFilterSheet({
  required BuildContext context,
  required List<String> locationOptions,
  required MarketplaceFilterSelection initialSelection,
}) async {
  return showModalBottomSheet<MarketplaceFilterSelection>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return _MarketplaceFilterSheetContent(
        locationOptions: locationOptions,
        initialSelection: initialSelection,
      );
    },
  );
}

class _MarketplaceFilterSheetContent extends StatefulWidget {
  final List<String> locationOptions;
  final MarketplaceFilterSelection initialSelection;

  const _MarketplaceFilterSheetContent({
    required this.locationOptions,
    required this.initialSelection,
  });

  @override
  State<_MarketplaceFilterSheetContent> createState() =>
      _MarketplaceFilterSheetContentState();
}

class _MarketplaceFilterSheetContentState
    extends State<_MarketplaceFilterSheetContent> {
  late String _tempLocation;
  late String _tempStatus;
  late final TextEditingController _tempMinSalaryController;
  late final TextEditingController _tempMaxSalaryController;

  @override
  void initState() {
    super.initState();
    _tempLocation = widget.initialSelection.location;
    _tempStatus = widget.initialSelection.status;
    _tempMinSalaryController = TextEditingController(
      text: widget.initialSelection.minSalary,
    );
    _tempMaxSalaryController = TextEditingController(
      text: widget.initialSelection.maxSalary,
    );
  }

  @override
  void dispose() {
    _tempMinSalaryController.dispose();
    _tempMaxSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter jobs',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tempLocation,
                    isExpanded: true,
                    items: widget.locationOptions
                        .map(
                          (location) => DropdownMenuItem(
                            value: location,
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _tempLocation = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tempStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(
                        value: 'assigned',
                        child: Text('Assigned'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _tempStatus = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempMinSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Salary',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _tempMaxSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Salary',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tempLocation = 'All';
                        _tempStatus = 'All';
                        _tempMinSalaryController.clear();
                        _tempMaxSalaryController.clear();
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MarketplaceFilterSelection(
                          location: _tempLocation,
                          status: _tempStatus,
                          minSalary: _tempMinSalaryController.text,
                          maxSalary: _tempMaxSalaryController.text,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
