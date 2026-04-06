import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/marketplace_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const BarangayMicrojobsApp());
}

class BarangayMicrojobsApp extends StatelessWidget {
  const BarangayMicrojobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true);
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF0D5C63),
      onPrimary: Colors.white,
      secondary: Color(0xFFDB7C26),
      onSecondary: Colors.white,
      surface: Color(0xFFFFFCF6),
      onSurface: Color(0xFF1A1A1A),
      error: Color(0xFFB42318),
    );

    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 48,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 40,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 34,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        fontSize: 21,
      ),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, height: 1.4),
      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );

    return MaterialApp(
      title: 'Barangay Microjobs',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: textTheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F2E9),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: textTheme.titleLarge,
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.88),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: textTheme.labelLarge,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.onSurface,
          contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const HomePage() : const LoginScreen();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Barangay Microjobs')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.surface, const Color(0xFFF8F2E9)],
          ),
        ),
        child: _buildBody(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
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
        return const HistoryScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const MarketplaceScreen();
    }
  }
}
