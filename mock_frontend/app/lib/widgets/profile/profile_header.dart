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
  static const String _apiBaseUrl = 'http://10.0.2.2:8000';
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  String _resolveImageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$_apiBaseUrl$trimmed';
    }
    return '$_apiBaseUrl/$trimmed';
  }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
    final colorScheme = Theme.of(context).colorScheme;
    final fullName = widget.userData?['full_name'] ?? 'User';
    final rating = (widget.userData?['rating'] ?? 0.0).toStringAsFixed(1);
    final reviewCount = widget.userData?['review_count'] ?? 0;
    final profileImage = widget.userData?['profile_image'];
    final profileImageUrl =
        (profileImage != null && profileImage.toString().trim().isNotEmpty)
        ? _resolveImageUrl(profileImage.toString())
        : null;
    final phone = widget.userData?['phone_number']?.toString() ?? 'No phone';
    final role = (widget.userData?['role'] ?? 'resident').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (profileImageUrl != null && profileImageUrl.isNotEmpty)
                      ? NetworkImage(profileImageUrl) as ImageProvider
                      : null,
                  child:
                      (_selectedImage == null &&
                          (profileImageUrl == null || profileImageUrl.isEmpty))
                      ? const Icon(Icons.person, size: 52, color: Colors.white)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 19,
                    ),
                    onPressed: _showImageSourceDialog,
                    iconSize: 19,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            fullName,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 23,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _infoChip(
                icon: Icons.verified_user_outlined,
                label: role.toUpperCase(),
                color: colorScheme.primary,
              ),
              _infoChip(
                icon: Icons.star_rounded,
                label: '$rating ($reviewCount reviews)',
                color: colorScheme.secondary,
              ),
              _infoChip(
                icon: Icons.phone_outlined,
                label: phone,
                color: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
