import 'package:flutter/material.dart';

import '../actions/job_action_buttons.dart';

class JobDetailsActionPanel extends StatelessWidget {
  final bool isJobPoster;
  final bool isJobOpen;
  final String jobStatus;
  final bool hasApplied;
  final bool isLoading;
  final VoidCallback onApplyPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;

  const JobDetailsActionPanel({
    required this.isJobPoster,
    required this.isJobOpen,
    required this.jobStatus,
    required this.hasApplied,
    required this.isLoading,
    required this.onApplyPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isJobPoster ? 'Management Action' : 'Application Action',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          JobActionButtons(
            isJobPoster: isJobPoster,
            hasApplied: hasApplied,
            isJobOpen: isJobOpen,
            jobStatus: jobStatus,
            isLoading: isLoading,
            onApplyPressed: onApplyPressed,
            onDeletePressed: onDeletePressed,
            onEditPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}
