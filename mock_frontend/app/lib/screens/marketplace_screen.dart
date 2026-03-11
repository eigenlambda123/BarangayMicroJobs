import 'package:flutter/material.dart';
import '../widgets/posting_card.dart';
import '../widgets/post_job_modal.dart';
import 'job_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  bool _showPostJobModal = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 32),
                _buildActivePostingsSection(context),
              ],
            ),
          ),
        ),
        // Post Job Modal Overlay
        if (_showPostJobModal)
          GestureDetector(
            onTap: () {
              setState(() => _showPostJobModal = false);
            },
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: PostJobModal(
                  onClose: () {
                    setState(() => _showPostJobModal = false);
                  },
                  onSubmit: () {
                    setState(() => _showPostJobModal = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job posted successfully!')),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BMJ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BARANGAY MICROJOBS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '● ONLINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() => _showPostJobModal = true);
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('POST JOB'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildActivePostingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Active Postings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'MANAGE HELP IN ZONE 1',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PostingCard(
          title: 'Laundry Help (Wash & Fold)',
          price: '₱200',
          zone: 'ZONE 1',
          applicants: 2,
          status: 'OPEN',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const JobDetailsScreen(
                  jobTitle: 'Laundry Help (Wash & Fold)',
                  price: '₱200',
                  zone: 'ZONE 1',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
