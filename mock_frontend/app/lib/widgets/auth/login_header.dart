import 'package:flutter/material.dart';
import '../common/brand_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandLogo(height: 66),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'Community marketplace',
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ),
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
