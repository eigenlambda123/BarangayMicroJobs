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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_errorMessage != null) {
      return ErrorState(errorMessage: _errorMessage!, onRetry: _loadUserData);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final role = (_userData?['role'] ?? 'resident').toString();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFCF6), Color(0xFFF4EEE4)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDAD2C7)),
                ),
                child: const Text(
                  'Manage your profile photo, view reputation, and track your contribution in the community.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616A70),
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
              LogoutButton(onPressed: _handleLogout),
            ],
          ),
        ),
      ),
    );
  }
}
