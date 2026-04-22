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
  var tempLocation = initialSelection.location;
  var tempStatus = initialSelection.status;
  final tempMinSalaryController = TextEditingController(
    text: initialSelection.minSalary,
  );
  final tempMaxSalaryController = TextEditingController(
    text: initialSelection.maxSalary,
  );

  try {
    return await showModalBottomSheet<MarketplaceFilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tempLocation,
                            isExpanded: true,
                            items: locationOptions
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
                              setSheetState(() => tempLocation = value);
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
                            value: tempStatus,
                            items: const [
                              DropdownMenuItem(
                                value: 'All',
                                child: Text('All statuses'),
                              ),
                              DropdownMenuItem(
                                value: 'open',
                                child: Text('Open'),
                              ),
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
                              setSheetState(() => tempStatus = value);
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
                            controller: tempMinSalaryController,
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
                            controller: tempMaxSalaryController,
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
                              setSheetState(() {
                                tempLocation = 'All';
                                tempStatus = 'All';
                                tempMinSalaryController.clear();
                                tempMaxSalaryController.clear();
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
                                  location: tempLocation,
                                  status: tempStatus,
                                  minSalary: tempMinSalaryController.text,
                                  maxSalary: tempMaxSalaryController.text,
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
          },
        );
      },
    );
  } finally {
    tempMinSalaryController.dispose();
    tempMaxSalaryController.dispose();
  }
}
