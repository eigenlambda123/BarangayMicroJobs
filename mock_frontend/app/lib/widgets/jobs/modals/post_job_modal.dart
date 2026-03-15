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
  String _location = 'Zone 1';
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
                      value: _location,
                      items: const [
                        DropdownMenuItem(
                          value: 'Zone 1',
                          child: Text('Location 1'),
                        ),
                        DropdownMenuItem(
                          value: 'Zone 2',
                          child: Text('Location 2'),
                        ),
                        DropdownMenuItem(
                          value: 'Zone 3',
                          child: Text('Location 3'),
                        ),
                        DropdownMenuItem(
                          value: 'Zone 4',
                          child: Text('Location 4'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _location = value ?? 'Zone 1');
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
