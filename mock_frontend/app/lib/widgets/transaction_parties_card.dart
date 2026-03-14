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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parties Involved',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Job Poster: ${requester['name']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.work, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Service Provider: ${provider['name']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
