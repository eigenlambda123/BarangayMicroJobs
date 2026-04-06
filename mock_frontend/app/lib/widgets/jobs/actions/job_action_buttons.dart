import 'package:flutter/material.dart';

class JobActionButtons extends StatelessWidget {
  final bool isJobPoster;
  final bool hasApplied;
  final bool isJobOpen;
  final bool isLoading;
  final VoidCallback onApplyPressed;
  final VoidCallback onDeletePressed;

  const JobActionButtons({
    super.key,
    required this.isJobPoster,
    required this.hasApplied,
    required this.isJobOpen,
    required this.isLoading,
    required this.onApplyPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isJobPoster)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasApplied
                  ? null
                  : (!isJobOpen)
                  ? null
                  : (isLoading ? null : onApplyPressed),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                hasApplied
                    ? 'Applied'
                    : (!isJobOpen)
                    ? 'Job Not Open'
                    : (isLoading ? 'Applying...' : 'Apply for Job'),
              ),
              style: hasApplied
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    )
                  : null,
            ),
          ),
        if (isJobPoster)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDeletePressed,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Job'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
