import 'package:flutter/material.dart';
import '../../../services/job_service.dart';

/// Card widget for displaying and editing job details
class JobDetailsCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback onJobUpdated;

  const JobDetailsCard({
    required this.job,
    required this.onJobUpdated,
    super.key,
  });

  @override
  State<JobDetailsCard> createState() => _JobDetailsCardState();
}

class _JobDetailsCardState extends State<JobDetailsCard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryController;
  late TextEditingController _locationController;
  bool _isEditMode = false;
  bool _isSaving = false;
  String? _selectedLocation;

  static const List<String> _lucenaBarangays = [
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.job['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.job['description'] ?? '');
    _salaryController =
        TextEditingController(text: (widget.job['salary'] ?? 0).toString());
    _locationController =
        TextEditingController(text: widget.job['location'] ?? '');
    _selectedLocation = widget.job['location'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await JobService().updateJob(
        jobId: widget.job['id'].toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        location: _selectedLocation ?? widget.job['location'],
        salary: _salaryController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job updated successfully')),
        );
        setState(() => _isEditMode = false);
        widget.onJobUpdated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _handleCancel() {
    _initializeControllers();
    setState(() => _isEditMode = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isEditMode) {
      return _buildEditMode(colorScheme);
    }

    return _buildViewMode(colorScheme);
  }

  Widget _buildViewMode(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.job['title'] ?? 'Untitled Job',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EED6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '₱${widget.job['salary'] ?? 0}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            (widget.job['description'] ?? 'No description available')
                .toString(),
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(
                colorScheme: colorScheme,
                icon: Icons.location_on_outlined,
                label: (widget.job['location'] ?? 'Unknown location')
                    .toString(),
              ),
              _metaChip(
                colorScheme: colorScheme,
                icon: Icons.schedule_outlined,
                label: 'Transaction linked',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isEditMode = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Job'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Job Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'JOB TITLE',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  items: _lucenaBarangays
                      .map(
                        (barangay) => DropdownMenuItem(
                          value: barangay,
                          child: Text(
                            barangay,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedLocation = value);
                  },
                  decoration: InputDecoration(
                    labelText: 'LOCATION',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'BUDGET (₱)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'DESCRIPTION',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _handleCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSaveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C63),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 1),
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
