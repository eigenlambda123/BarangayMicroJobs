import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/launch_gate.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';

class BarangayMicrojobsApp extends StatelessWidget {
  const BarangayMicrojobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF0D5C63),
      onPrimary: Colors.white,
      secondary: Color(0xFFDB7C26),
      onSecondary: Colors.white,
      surface: Color(0xFFFFFCF6),
      onSurface: Color(0xFF1D2428),
      error: Color(0xFFB42318),
    );

    return MaterialApp(
      title: 'Barangay Microjobs',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4EEE4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1D2428),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          height: 72,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colorScheme.primary : const Color(0xFF6A7278),
            );
          }),
        ),
        useMaterial3: true,
      ),
      home: const LaunchGate(),
      routes: {
        '/home': (context) => const HomePage(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
