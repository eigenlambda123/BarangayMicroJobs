import 'package:flutter/material.dart';
import '../common/brand_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandLogo(height: isPhone ? 96 : 72),
        const SizedBox(height: 48),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,

            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to continue to Barangay Microjobs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
