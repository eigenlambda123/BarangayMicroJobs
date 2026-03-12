import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  Future<void> _loadUserData() async {
    try {
      final token = await AuthService().getToken();
      if (token != null) {
        final userData = await AuthService().getCurrentUser(token);
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: ${e.toString()}';
          _isLoading = false;
        });
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'My Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            // _buildProviderToggle(),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final fullName = _userData?['full_name'] ?? 'User';
    final rating = (_userData?['rating'] ?? 0.0).toStringAsFixed(1);
    final reviewCount = _userData?['review_count'] ?? 0;

    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 50, color: Colors.white),
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

  // Widget _buildProviderToggle() {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Service Provider',
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 isServiceProvider ? 'Enabled' : 'Disabled',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   color: isServiceProvider ? Colors.green : Colors.grey,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Switch(
  //             value: isServiceProvider,
  //             onChanged: (value) {
  //               setState(() {
  //                 isServiceProvider = value;
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatsCard() {
    final jobsDone = _userData?['jobs_done'] ?? 0;
    final jobsPosted = _userData?['jobs_posted'] ?? 0;
    final totalEarned = (_userData?['total_earned'] ?? 0.0).toStringAsFixed(2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(jobsDone.toString(), 'Jobs Done'),
            _buildStatItem(jobsPosted.toString(), 'Posted'),
            _buildStatItem('₱$totalEarned', 'Earned'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _handleLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size.fromHeight(48),
      ),
      child: const Text('Logout'),
    );
  }
}
