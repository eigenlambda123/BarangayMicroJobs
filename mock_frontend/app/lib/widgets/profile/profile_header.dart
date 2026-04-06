import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileHeader extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(File)? onImageSelected;

  const ProfileHeader({
    super.key, 
    required this.userData,
    this.onImageSelected,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
        // Call the callback to handle image upload
        widget.onImageSelected?.call(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: const Text('Select where to pick your profile picture from:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.userData?['full_name'] ?? 'User';
    final rating = (widget.userData?['rating'] ?? 0.0).toStringAsFixed(1);
    final reviewCount = widget.userData?['review_count'] ?? 0;
    final profileImage = widget.userData?['profile_image'];

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  backgroundImage: _selectedImage != null 
                    ? FileImage(_selectedImage!)
                    : (profileImage != null && profileImage.isNotEmpty)
                      ? NetworkImage(profileImage) as ImageProvider
                      : null,
                  child: (_selectedImage == null && 
                         (profileImage == null || profileImage.isEmpty))
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _showImageSourceDialog,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text('$rating ($reviewCount reviews)'),
            ],
          ),
        ],
      ),
    );
  }
}
