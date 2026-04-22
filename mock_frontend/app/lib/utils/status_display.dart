import 'package:flutter/material.dart';

class StatusDisplay {
  static String normalize(String? status) {
    return (status ?? '').trim().toLowerCase();
  }

  static String label(String? status) {
    switch (normalize(status)) {
      case 'open':
        return 'Open';
      case 'assigned':
      case 'hired':
        return 'Assigned';
      case 'applied':
        return 'Applied';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      default:
        final normalized = normalize(status);
        if (normalized.isEmpty) return 'Unknown';
        return normalized[0].toUpperCase() + normalized.substring(1);
    }
  }

  static Color color(String? status, ColorScheme colorScheme) {
    switch (normalize(status)) {
      case 'open':
        return const Color(0xFF0D5C63);
      case 'assigned':
      case 'hired':
      case 'applied':
        return const Color(0xFFDB7C26);
      case 'completed':
        return const Color(0xFF2A6A31);
      case 'canceled':
        return const Color(0xFFB42318);
      default:
        return colorScheme.onSurface.withValues(alpha: 0.54);
    }
  }
}
