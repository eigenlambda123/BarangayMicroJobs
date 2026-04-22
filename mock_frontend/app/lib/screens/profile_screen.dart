import 'package:flutter/material.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../widgets/common/loading_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/stats_card.dart';
import '../widgets/profile/logout_button.dart';
import '../widgets/profile/profile_details_section.dart';

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
    try {
      await AuthService().updateProfileImage(imageFile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
        _loadUserData();
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

  void _handleEditToggle() {
    setState(() => _isEditMode = !_isEditMode);
    if (!_isEditMode) {
      _phoneController.text = _userData?['phone_number'] ?? '';
      _emailController.text = _userData?['email'] ?? '';
      _locationController.text = _userData?['location'] ?? '';
      _skillInputController.clear();
      _skills = List<String>.from(_userData?['skills'] ?? []);
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
              ProfileDetailsSection(
                isEditMode: _isEditMode,
                isSaving: _isSaving,
                phoneController: _phoneController,
                emailController: _emailController,
                locationController: _locationController,
                skillInputController: _skillInputController,
                skills: _skills,
                onToggleEdit: _handleEditToggle,
                onSave: _saveProfileChanges,
                onAddSkill: _addSkill,
                onRemoveSkill: _removeSkill,
              ),
              const SizedBox(height: 16),
              LogoutButton(onPressed: _handleLogout),
            ],
          ),
        ),
      ),
    );
  }
}
