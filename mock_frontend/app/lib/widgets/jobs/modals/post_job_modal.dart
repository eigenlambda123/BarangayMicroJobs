import 'package:flutter/material.dart';
import '../../../services/job_service.dart';

class PostJobModal extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const PostJobModal({
    required this.onClose,
    required this.onSubmit,
    super.key,
  });

  @override
  State<PostJobModal> createState() => _PostJobModalState();
}

class _PostJobModalState extends State<PostJobModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _imageController = TextEditingController();
  static const List<String> _lucenaBarangays = [
    'Barangay 1',
    'Barangay 2',
    'Barangay 3',
    'Barangay 4',
    'Barangay 5',
    'Barangay 6',
    'Barangay 7',
    'Barangay 8',
    'Barangay 9',
    'Barangay 10',
    'Barangay 11',
    'Barangay 12',
    'Barangay 13',
    'Barangay 14',
    'Barangay 15',
    'Barangay 16',
    'Barangay 17',
    'Barangay 18',
    'Barangay 19',
    'Barangay 20',
    'Barangay 21',
    'Barangay 22',
    'Barangay 23',
    'Barangay 24',
    'Barangay 25',
    'Barangay 26',
    'Barangay 27',
    'Barangay 28',
    'Barangay 29',
    'Barangay 30',
    'Barangay 31',
    'Barangay 32',
    'Barangay 33',
    'Barangay 34',
    'Barangay 35',
    'Barangay 36',
    'Barangay 37',
    'Barangay 38',
    'Barangay 39',
    'Barangay 40',
    'Barangay 41',
    'Barangay 42',
    'Barangay 43',
    'Barangay 44',
    'Barangay 45',
    'Barangay 46',
    'Barangay 47',
    'Barangay 48',
    'Barangay 49',
    'Barangay 50',
    'Barangay 51',
    'Barangay 52',
    'Barangay 53',
    'Barangay 54',
    'Barangay 55',
    'Barangay 56',
    'Barangay 57',
    'Barangay 58',
    'Barangay 59',
    'Barangay 60',
    'Barangay 61',
    'Barangay 62',
    'Barangay 63',
    'Barangay 64',
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

  String _location = _lucenaBarangays.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _handlePostJob() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await JobService().createJob(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _location,
        salary: _salaryController.text,
        image: _imageController.text.isNotEmpty ? _imageController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job posted successfully! ID: ${result['job_id']}'),
          ),
        );
        widget.onSubmit();
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Post a Micro-Job',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'JOB TITLE',
                  hintText: 'e.g. Help carrying groceries',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _location,
                      items: _lucenaBarangays
                          .map(
                            (barangay) => DropdownMenuItem(
                              value: barangay,
                              child: Text(barangay),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(
                          () => _location = value ?? _lucenaBarangays.first,
                        );
                      },
                      decoration: const InputDecoration(
                        labelText: 'LOCATION',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'BUDGET (₱)',
                        hintText: '200',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'DESCRIPTION',
                  hintText: 'What do you need help with?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'IMAGE URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePostJob,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post Job Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
