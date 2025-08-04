import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for assets
    final List<Map<String, dynamic>> assets = [
      {'name': 'USDT', 'amount': 500.00, 'value': 500.00},
      {'name': 'BNB', 'amount': 2.50, 'value': 1500.00},
      {'name': 'BTC', 'amount': 0.05, 'value': 3000.00},
      {'name': 'ETH', 'amount': 1.20, 'value': 2800.00},
      {'name': 'TON', 'amount': 10.00, 'value': 600.00},
      {'name': 'XRP', 'amount': 100.00, 'value': 200.00},
      {'name': 'TCIS', 'amount': 50.00, 'value': 450.00},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1E3D),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFF1E3A8A),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'John Doe',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'john.doe@example.com',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '\$8,050.00',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {},
                        child: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {},
                        child: const Text('Receive', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {},
                        child: const Text('Swap', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Assets List
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: ListView.builder(
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return Card(
                      color: const Color(0xFF1E3A8A),
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 20,
                          child: Text(
                            asset['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        title: Text(
                          asset['name'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${asset['amount']} ${asset['name']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        trailing: Text(
                          '\$${asset['value'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E3A8A),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.white70,
        currentIndex: 0, // Default to first tab
        onTap: (index) {
          // Handle navigation
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Swap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}