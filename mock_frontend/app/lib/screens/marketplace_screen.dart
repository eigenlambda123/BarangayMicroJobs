import 'package:flutter/material.dart';
import '../widgets/posting_card.dart';
import '../widgets/applicant_card.dart';
import '../widgets/post_job_modal.dart';

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
                const SizedBox(height: 16),
                _buildReviewApplicantsSection(context),
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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
            label: const Text('NEED HELP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _showPostJobModal = true);
            },
            icon: const Icon(Icons.work_outline),
            label: const Text('WANT WORK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
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
        const PostingCard(
          title: 'Laundry Help (Wash & Fold)',
          price: '₱200',
          zone: 'ZONE 1',
          applicants: 2,
          status: 'OPEN',
        ),
      ],
    );
  }

  Widget _buildReviewApplicantsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Applicants',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'LAUNDRY HELP (WASH & FOLD)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ApplicantCard(
          name: 'Ricardo Dalisay',
          rating: 4.9,
          reviewCount: 40,
          timeAvailable: '1Hrs Now',
          onHirePressed: () {},
          onMessagePressed: () {},
          onViewProfilePressed: () {},
        ),
        const SizedBox(height: 8),
        ApplicantCard(
          name: 'Santi Garcia',
          rating: 4.7,
          reviewCount: 12,
          timeAvailable: '2Hrs Now',
          onHirePressed: () {},
          onMessagePressed: () {},
          onViewProfilePressed: () {},
        ),
      ],
    );
  }
}
