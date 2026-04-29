import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double height;
  final double? width;

  const BrandLogo({super.key, this.height = 32, this.width});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Image.asset(
      'assets/app_logo.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 26, height: 26),
            const SizedBox(width: 10),
            Text(
              'Barangay Microjobs',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      },
    );
  }
}
