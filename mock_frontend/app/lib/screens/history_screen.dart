import 'package:flutter/material.dart';
import '../widgets/activity_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Activity History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ActivityCard(
                  title: 'Fan Repair',
                  price: '₱150',
                  date: 'JAN 14, 2025',
                  status: 'COMPLETED',
                  statusColor: Colors.green,
                  worker: 'RICARDO DALISAY',
                  onRatePressed: () {},
                ),
                const SizedBox(height: 12),
                ActivityCard(
                  title: 'Document Filing',
                  price: '₱100',
                  date: 'FEB 11, 2025',
                  status: 'RATED',
                  statusColor: Colors.amber,
                  worker: 'SANTI GARCIA',
                  onRatePressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
