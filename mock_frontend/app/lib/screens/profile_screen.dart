import 'package:flutter/material.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/stats_card.dart';
import '../widgets/profile/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isServiceProvider = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditMode = false;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _skillInputController;
  List<String> _skills = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _locationController = TextEditingController();
    _skillInputController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _redirectToLogin() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _loadUserData() async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        _redirectToLogin();
        return;
      }

      final userData = await AuthService().getCurrentUser();
      if (mounted) {
        _phoneController.text = userData['phone_number'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _locationController.text = userData['location'] ?? '';
        _skills = List<String>.from(userData['skills'] ?? []);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('session expired') ||
          errorText.contains('not authenticated')) {
        _redirectToLogin();
        return;
      }

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleImageSelected(File imageFile) async {
    // For now, we'll use the file path as a placeholder
    // In a real app, you'd upload the image to a server and get a URL
    try {
      await AuthService().updateProfileImage(imageFile.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
        _loadUserData(); // Reload user data to show updated image
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile image: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _saveProfileChanges() async {
    setState(() => _isSaving = true);
    try {
      await AuthService().updateProfile(
        phone: _phoneController.text,
        email: _emailController.text,
        location: _locationController.text,
        skills: _skills,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isEditMode = false;
        });
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_errorMessage != null) {
      return ErrorState(errorMessage: _errorMessage!, onRetry: _loadUserData);
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  'Manage your profile photo, view reputation, and track your contribution in the community.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.66),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ProfileHeader(
                userData: _userData,
                onImageSelected: _handleImageSelected,
              ),
              const SizedBox(height: 14),
              StatsCard(userData: _userData),
              const SizedBox(height: 16),
              _buildEditProfileSection(colorScheme),
              const SizedBox(height: 16),
              LogoutButton(onPressed: _handleLogout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () {
                setState(() => _isEditMode = !_isEditMode);
                if (!_isEditMode) {
                  _phoneController.text = _userData?['phone_number'] ?? '';
                  _emailController.text = _userData?['email'] ?? '';
                  _locationController.text = _userData?['location'] ?? '';
                }
              },
              child: Text(_isEditMode ? 'Cancel' : 'Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isEditMode) ...[
          _buildEditMode(colorScheme),
        ] else ...[
          _buildViewMode(colorScheme),
        ],
      ],
    );
  }

  Widget _buildViewMode(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Phone', _phoneController.text, colorScheme),
          const SizedBox(height: 12),
          _buildDetailRow('Email', _emailController.text, colorScheme),
          const SizedBox(height: 12),
          _buildDetailRow('Location', _locationController.text, colorScheme),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSkillsView(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Not provided' : value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value.isEmpty
                ? colorScheme.onSurface.withValues(alpha: 0.4)
                : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsView(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _skills
              .map(
                (skill) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditMode(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditField('Phone', _phoneController, colorScheme),
          const SizedBox(height: 14),
          _buildEditField('Email', _emailController, colorScheme),
          const SizedBox(height: 14),
          _buildEditField('Location', _locationController, colorScheme),
          const SizedBox(height: 16),
          _buildSkillsEditor(colorScheme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveProfileChanges,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSaving
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: !_isSaving,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsEditor(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillInputController,
                enabled: !_isSaving,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add skill',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSaving ? null : _addSkill,
              icon: Icon(Icons.add_circle, color: colorScheme.primary),
            ),
          ],
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildSkillChips(colorScheme),
        ],
      ],
    );
  }

  Widget _buildSkillChips(ColorScheme colorScheme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _skills
          .map(
            (skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _isSaving ? null : () => _removeSkill(skill),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
