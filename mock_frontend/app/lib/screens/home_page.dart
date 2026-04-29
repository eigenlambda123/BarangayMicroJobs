import 'package:flutter/material.dart';

import '../widgets/common/brand_logo.dart';
import 'history_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'my_applications_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void switchToMarketplace() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    // Always start at Marketplace tab when HomePage is created (e.g., on login)
    _selectedIndex = 0;
  }

  static const List<String> _titles = [
    'Marketplace',
    'My Jobs',
    'My Applications',
    'Profile',
  ];

  static const List<String> _subtitles = [
    'Find opportunities posted by other users',
    'Manage the jobs you have posted',
    'Track the status of your applications',
    'Manage your account and preferences',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: const BrandLogo(height: 28),
        ),
      ),
      body: Container(
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _buildBody(_selectedIndex),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: colorScheme.primary),
            label: _titles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work, color: colorScheme.primary),
            label: _titles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: colorScheme.primary),
            label: _titles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: colorScheme.primary),
            label: _titles[3],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const MarketplaceScreen();
      case 1:
        return HistoryScreen(onGoToMarketplace: switchToMarketplace);
      case 2:
        return const MyApplicationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const MarketplaceScreen();
    }
  }
}
