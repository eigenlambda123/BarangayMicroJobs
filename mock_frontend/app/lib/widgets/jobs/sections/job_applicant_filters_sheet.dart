import 'package:flutter/material.dart';

Future<JobApplicantFilterSelection?> showJobApplicantFiltersSheet({
  required BuildContext context,
  required JobApplicantFilterSelection initialSelection,
}) async {
  var tempStatus = initialSelection.status;
  final tempMinRatingController = TextEditingController(
    text: initialSelection.minRating,
  );
  final tempSkillsController = TextEditingController(
    text: initialSelection.skills,
  );

  try {
    return await showModalBottomSheet<JobApplicantFilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      'Filter applicants',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'applied',
                          child: Text('Applied'),
                        ),
                        DropdownMenuItem(value: 'hired', child: Text('Hired')),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'canceled',
                          child: Text('Canceled'),
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: tempMinRatingController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Min Rating',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tempSkillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills (comma-separated)',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                tempStatus = 'All';
                                tempMinRatingController.clear();
                                tempSkillsController.clear();
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
                                JobApplicantFilterSelection(
                                  status: tempStatus,
                                  minRating: tempMinRatingController.text,
                                  skills: tempSkillsController.text,
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
    tempMinRatingController.dispose();
    tempSkillsController.dispose();
  }
}

class JobApplicantFilterSelection {
  final String status;
  final String minRating;
  final String skills;

  const JobApplicantFilterSelection({
    required this.status,
    required this.minRating,
    required this.skills,
  });

  const JobApplicantFilterSelection.initial()
    : status = 'All',
      minRating = '',
      skills = '';

  int get activeFilterCount {
    var count = 0;
    if (status != 'All') count++;
    if (minRating.trim().isNotEmpty) count++;
    if (skills.trim().isNotEmpty) count++;
    return count;
  }

  bool get hasFilters => activeFilterCount > 0;
}
