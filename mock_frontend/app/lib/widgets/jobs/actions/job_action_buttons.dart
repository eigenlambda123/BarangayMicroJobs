import 'package:flutter/material.dart';

class JobActionButtons extends StatelessWidget {
  final bool isJobPoster;
  final bool hasApplied;
  final bool isJobOpen;
  final bool isLoading;
  final VoidCallback onApplyPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;

  const JobActionButtons({
    super.key,
    required this.isJobPoster,
    required this.hasApplied,
    required this.isJobOpen,
    required this.isLoading,
    required this.onApplyPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
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
                      backgroundColor: colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                      foregroundColor: colorScheme.onPrimary,
                    )
                  : null,
            ),
          ),
        if (isJobPoster)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C63),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDeletePressed,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
