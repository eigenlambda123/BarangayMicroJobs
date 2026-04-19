import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

enum _LaunchDestination { onboarding, login, home }

class LaunchGate extends StatefulWidget {
  const LaunchGate({super.key});

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  late Future<_LaunchDestination> _launchDestination;

  @override
  void initState() {
    super.initState();
    _launchDestination = _resolveLaunchDestination();
  }

  Future<_LaunchDestination> _resolveLaunchDestination() async {
    final onboardingSeen = await OnboardingScreen.isCompleted();
    if (!onboardingSeen) {
      return _LaunchDestination.onboarding;
    }

    final isLoggedIn = await AuthService().isLoggedIn();
    return isLoggedIn ? _LaunchDestination.home : _LaunchDestination.login;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LaunchDestination>(
      future: _launchDestination,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScaffold();
        }

        switch (snapshot.data) {
          case _LaunchDestination.onboarding:
            return const OnboardingScreen();
          case _LaunchDestination.home:
            return const HomePage();
          case _LaunchDestination.login:
          default:
            return const LoginScreen();
        }
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
          return const _LoadingScaffold();
        }

        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const HomePage() : const LoginScreen();
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
