import 'package:flutter/material.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131718),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131718),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TCIS Wallet',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/usdt_icon.png', // Replace with your USDT icon asset
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Receive USDT',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'on the Ethereum network',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code, size: 150, color: Colors.grey), // Replace with actual QR code widget
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Text(
                    '0xdB89fADc4fe1DB88Ca5d7fE77c3',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '17af6FC19',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey, size: 16),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/exchange_icon.png', // Replace with your exchange icon
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Deposit from TCIS Wallet Exchange',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'This address can only receive USDT (Ethereum) assets.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}