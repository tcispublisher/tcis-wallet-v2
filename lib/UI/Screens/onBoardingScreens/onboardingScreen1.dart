import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../socialLogin/socialLogin.dart';

class FullScreenVideoSplash extends StatefulWidget {
  const FullScreenVideoSplash({super.key});

  @override
  _FullScreenVideoSplashState createState() => _FullScreenVideoSplashState();
}

class _FullScreenVideoSplashState extends State<FullScreenVideoSplash> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
        ..initialize().then((_) {
          _controller.setVolume(1.0);
          _controller.play();
          setState(() => _isInitialized = true);

          _controller.addListener(() {
            if (_controller.value.position >= _controller.value.duration) {
              _navigateToNextScreen();
            }
          });
        });
    } catch (e) {
      debugPrint("Video initialization error: $e");
    }
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SocialLogin()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video full screen
          if (_isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          // Nút "Let's get started" ở giữa, cách bottom 50px
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2B56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _navigateToNextScreen,
                child: const Text(
                  "Let's get started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}