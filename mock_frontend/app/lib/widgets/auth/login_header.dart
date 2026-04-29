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
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Community marketplace',
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text('Log In', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 12),
        Text(
          'Welcome back to Barangay Microjobs',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
