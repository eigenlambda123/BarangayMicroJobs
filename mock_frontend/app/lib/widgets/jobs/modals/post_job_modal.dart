import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
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

  String _location = _lucenaBarangays.first;
  Uint8List? _selectedImageBytes;
  String? _selectedImageData;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      final mimeType = _getMimeType(file.name);
      final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';

      if (mounted) {
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageData = dataUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
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
        image: _selectedImageData,
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
                      selectedItemBuilder: (context) {
                        return _lucenaBarangays
                            .map(
                              (barangay) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  barangay,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList();
                      },
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
                  const SizedBox(width: 8),
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
              const Text(
                'IMAGE (Optional)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Use Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose Photo'),
                    ),
                  ),
                ],
              ),
              if (_selectedImageBytes != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          _selectedImageBytes!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Image selected',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedImageBytes = null;
                            _selectedImageData = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        tooltip: 'Remove image',
                      ),
                    ],
                  ),
                ),
              ],
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
