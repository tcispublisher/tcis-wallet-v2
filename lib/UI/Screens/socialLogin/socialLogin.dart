import 'package:crypto_wallet/UI/Screens/dashboard_screen.dart';
import 'package:crypto_wallet/UI/Screens/socialLogin/verifyMnemonics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

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

  // List of video paths in assets
  final List<String> videoPaths = [
    'assets/videos/1.mp4',
    'assets/videos/2.mp4',
    'assets/videos/3.mp4',
  ];

  final List<Map<String, String>> videoTexts = [
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
  late List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
    // Initialize video controllers for each video
    _videoControllers = videoPaths.map((path) {
      final controller = VideoPlayerController.asset(path);
      controller.initialize().then((_) {
        setState(() {}); // Ensure the widget rebuilds after initialization
        if (_currentPage == videoPaths.indexOf(path)) {
          controller.play(); // Play the video on the current page
        }
      });
      // Add listener to detect when the video ends
      controller.addListener(() {
        if (controller.value.position >= controller.value.duration) {
          // Video has finished playing
          final nextPage = (_currentPage + 1) % videoPaths.length; // Loop back to 0 after the last video
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      return controller;
    }).toList();

    // Handle page changes to update video playback
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? _currentPage;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
        // Pause all videos
        for (var controller in _videoControllers) {
          controller.pause();
          controller.seekTo(Duration.zero); // Reset to start
        }
        // Play the video on the current page if initialized
        if (_videoControllers[page].value.isInitialized) {
          _videoControllers[page].play();
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose of all video controllers
    for (var controller in _videoControllers) {
      controller.dispose();
    }
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
            // Video Section (50% of screen)
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
                          itemCount: videoPaths.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _videoControllers[index].value.isInitialized
                                  ? VideoPlayer(_videoControllers[index])
                                  : const Center(child: CircularProgressIndicator()),
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
                      videoTexts[_currentPage]['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      videoTexts[_currentPage]['subtitle']!,
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
                children: List.generate(videoPaths.length, (index) {
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