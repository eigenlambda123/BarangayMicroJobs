import 'package:flutter/material.dart';

/// Card widget for displaying parties involved in the transaction
class TransactionPartiesCard extends StatelessWidget {
  final Map<String, dynamic> requester;
  final Map<String, dynamic> provider;

  const TransactionPartiesCard({
    required this.requester,
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAD2C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt_outlined, size: 18),
              SizedBox(width: 8),
              Text(
                'Parties Involved',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _partyTile(
            color: const Color(0xFF0D5C63),
            role: 'Job Poster',
            name: (requester['name'] ?? 'Unknown').toString(),
          ),
          const SizedBox(height: 10),
          _partyTile(
            color: const Color(0xFF2A6A31),
            role: 'Service Provider',
            name: (provider['name'] ?? 'Unknown').toString(),
          ),
        ],
      ),
    );
  }

  Widget _partyTile({
    required Color color,
    required String role,
    required String name,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
