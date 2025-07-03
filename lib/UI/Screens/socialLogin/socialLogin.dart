import 'package:crypto_wallet/UI/Screens/dashboard_screen.dart';
import 'package:crypto_wallet/UI/Screens/socialLogin/verifyMnemonics.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/bottomNavBar.dart';
import '../createWallet/createPin.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({super.key});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> gifUrls = [
    'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExOWJiZWd3azlxaG1nenZ5NGhxcDBsY3ZyMG9mdGozOWZlYnRyM3dzYiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/uBuzWfwVcadRC/giphy.gif',
    'https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExeG53YnR3ZXpvZ3h4c2txYjB5ZmZrdXMzeG94cWg1MzlwanNjNDY1biZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/NrCDULQ0RjxSM/giphy.gif',
    'https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExazc3OGxhOXZ2MnoxYnVqazJpOXoxa21sOGVqZWRzcG1kd2FmaDJtNCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/O5R4RttrYdBMk/giphy.gif',
  ];

  final List<Map<String, String>> gifTexts = [
    {
      'title': 'Start your crypto journey',
      'subtitle': 'Web3 made simple, seamless, and secure',
    },
    {
      'title': 'Your trusted Web3 wallet',
      'subtitle': 'Trusted by 80 million users',
    },
    {
      'title': 'Pay instantly with crypto',
      'subtitle': 'Scan. Send. Spend — Anytime, anywhere',
    },
  ];

  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.position.pixels == _pageController.position.minScrollExtent) {
        _pageController.jumpToPage(gifUrls.length - 1);
      } else if (_pageController.position.pixels == _pageController.position.maxScrollExtent) {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131718),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Processing...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        )
            : _statusMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // GIF Section (50% of screen)
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8, // Responsive width
                      child: AspectRatio(
                        aspectRatio: 1.0, // Equal height and width
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: gifUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: gifUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gifTexts[_currentPage]['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      gifTexts[_currentPage]['subtitle']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Pagination Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(gifUrls.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  );
                }),
              ),
            ),
            // Buttons Section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.to(() => const CreatePinScreen(
                          isImport: false,
                          walletAddress: "",
                          publicKey: "",
                          privateKey: "",
                          mnemonics: "",
                        )),
                        child: const Text(
                          "Create Wallet",
                          style: TextStyle(
                            color: Color(0xFF0A1E3D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                        onPressed: () => Get.to(() => VerifyMnemonicsScreen()),
                        child: const Text(
                          "Import Wallet",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        text: "By continuing, you agree to Bingst Wallet's ",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: " and ",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          TextSpan(
                            text: "User Agreement",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: ".",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}