import 'package:flutter/material.dart';

void main() {
  runApp(const BarangayMicrojobsApp());
}

class BarangayMicrojobsApp extends StatelessWidget {
  const BarangayMicrojobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Microjobs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barangay Microjobs'), elevation: 2),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeTab();
      case 1:
        return const JobsTab();
      case 2:
        return const PostJobTab();
      case 3:
        return const ProfileTab();
      default:
        return const HomeTab();
    }
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Welcome to Barangay Microjobs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Find local jobs and opportunities in your barangay',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureCard(
                  context,
                  Icons.work,
                  'Browse Jobs',
                  'Find available jobs',
                ),
                _buildFeatureCard(
                  context,
                  Icons.add_circle,
                  'Post a Job',
                  'Offer work to others',
                ),
                _buildFeatureCard(
                  context,
                  Icons.star,
                  'Ratings',
                  'View your reputation',
                ),
                _buildFeatureCard(
                  context,
                  Icons.payment,
                  'Transactions',
                  'Track your earnings',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Recent Jobs', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildJobPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'House Cleaning',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: const Text('₱500'),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Need help cleaning a 3-bedroom house',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Posted 2 hours ago',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                TextButton(onPressed: () {}, child: const Text('View')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Available Jobs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                JobCard(title: 'House Cleaning', price: '₱500'),
                JobCard(title: 'Yard Work', price: '₱300'),
                JobCard(title: 'Tutoring', price: '₱400'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String price;

  const JobCard({required this.title, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Posted by Member',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Apply')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostJobTab extends StatelessWidget {
  const PostJobTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Post a Job', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Job Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Budget (₱)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Post Job'),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('My Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                const Text(
                  'John Doe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text('4.8 (25 reviews)'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: const [
                      Text('12', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Jobs Done'),
                    ],
                  ),
                  Column(
                    children: const [
                      Text('8', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Posted'),
                    ],
                  ),
                  Column(
                    children: const [
                      Text(
                        '₱5,200',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Earned'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
