import 'package:flutter/material.dart';

class PostJobModal extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const PostJobModal({
    required this.onClose,
    required this.onSubmit,
    super.key,
  });

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
                    onTap: onClose,
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'JOB TITLE',
                  hintText: 'e.g. Help carrying groceries',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: const [
                        DropdownMenuItem(
                          value: 'manual',
                          child: Text('Manual Labor'),
                        ),
                        DropdownMenuItem(
                          value: 'domestic',
                          child: Text('Domestic Help'),
                        ),
                        DropdownMenuItem(
                          value: 'tutoring',
                          child: Text('Tutoring'),
                        ),
                      ],
                      onChanged: (value) {},
                      decoration: const InputDecoration(
                        labelText: 'CATEGORY',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const TextField(
                      decoration: InputDecoration(
                        labelText: 'BUDGET (₱)',
                        hintText: '200',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'DESCRIPTION',
                  hintText: 'What do you need help with?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Post Job Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
