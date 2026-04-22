import 'package:flutter/material.dart';

class MarketplaceBackgroundOrb extends StatelessWidget {
  const MarketplaceBackgroundOrb({
    required this.color,
    this.size = 220,
    super.key,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}
