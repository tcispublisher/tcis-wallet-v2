import 'dart:async';
import 'package:crypto_wallet/UI/Screens/onBoardingScreens/onboardingScreen1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../providers/wallet_provider.dart';
import '../../../services/apiService.dart';
import '../profile/accountMenuScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _videoController;
  bool _isLoading = true;
  bool _isDataLoading = true;
  String walletAddress = '';
  String privateKey = '';
  String accountName = '';
  double rewards = 0;
  final ScrollController _scrollController = ScrollController();
  dynamic reward = {};
  List<dynamic> userChoices = [];
  List<dynamic> trendings = [];
  List<dynamic> futures = [];
  List<dynamic> hold2Earns = [];
  bool _isInitialLoading = true; // Track initial load only
  bool _isRefreshing = false; // Track refresh state
  List coins=[];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _fetchData();
    _loadWalletData();
  }

  Future<void> _loadWalletData({bool isRefresh = false}) async {
    try {
      setState(() {
        if (!isRefresh) {
          _isInitialLoading = true; // Only set for initial load
        } else {
          _isRefreshing = true; // Set for refresh
        }
      });

      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.loadPrivateKey();

      String? savedWalletAddress = await walletProvider.getWalletAddress();
      if (savedWalletAddress == null) {
        throw Exception("Can't get the wallet address");
      }

      dynamic response = await ApiService.fetchStatistic(savedWalletAddress);

      setState(() {
        coins = response;
        rewards = coins[0]['rewards'];
        accountName = coins[0]['displayName'];
        walletAddress = savedWalletAddress;
        _isInitialLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
        _isRefreshing = false;
      });
      // Handle error if needed
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/intro_tcis.mp4');
      await _videoController.initialize();

      if (!mounted) return;

      setState(() {
        _videoController.setVolume(0);
        _videoController.setLooping(true);
        _videoController.play();
      });
    } catch (e) {
      debugPrint("Video initialization error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String formatTotalBalance(double value) {
    try {
      if (value == 0) {
        return "0.00";
      }

      if (value < 0.0001) {
        return NumberFormat("0.00", "en_US").format(value);
      }

      // Check if the number is whole (no decimal places)
      if (value == value.roundToDouble()) {
        return NumberFormat("#,##0", "en_US").format(value);
      }

      // Format with up to 8 decimal places
      NumberFormat formatter = NumberFormat()
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 8;

      return formatter.format(value);
    } catch (e) {
      return "Invalid balance";
    }
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isDataLoading = true;
      });

      final response = await ApiService.fetchHomeInfo();

      if (!mounted) return;

      setState(() {
        trendings = response['trendings'] ?? [];
        reward = response['reward'] ?? {};
        userChoices = response['usersChoices'] ?? [];
        futures = response['futures'] ?? [];
        hold2Earns = response['hold2Eearn'] ?? [];
        _isDataLoading = false;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) {
        setState(() {
          _isDataLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchData();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final videoHeight = screenSize.height * 0.5;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Colors.blue,
          backgroundColor: Colors.grey[900],
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildVideoSection(videoHeight),
              const SizedBox(height: 24),
              _buildDepositSection(),
              const SizedBox(height: 24),
              _buildRewardsSection(),
              _buildNewUsersChoiceSection(),
              _buildTrendingSection(),
              _buildFuturesSection(),
              _buildHold2EarnSection(),
              _buildHelpCenterSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection(double height) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          _isLoading || !_videoController.value.isInitialized
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : VideoPlayer(_videoController),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAppsButton(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'BTC/USDT 125X',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIcon('https://tcisscan.com/icons/bitget.png'),
                            const SizedBox(width: 4),
                            _buildIcon('https://tcisscan.com/icons/bnb.png'),
                            const SizedBox(width: 4),
                            _buildIcon('https://tcisscan.com/icons/okx.png'),
                            const SizedBox(width: 4),
                            Icon(Icons.circle, size: 4, color: Colors.grey),
                            const SizedBox(width: 4),
                            _buildIcon('https://tcisscan.com/icons/visa.png'),
                            const SizedBox(width: 4),
                            _buildIcon('https://tcisscan.com/icons/mastercard.png'),
                            const SizedBox(width: 4),
                            _buildIcon('https://tcisscan.com/icons/apple_pay.png'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crypto for Everyone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String fileName) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          fileName,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.error,
              size: 20,
              color: Colors.red,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildDepositSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDepositOption('Pay', Icons.payment),
            const SizedBox(width: 8),
            _buildDepositOption('FOMO', Icons.account_balance_wallet),
            const SizedBox(width: 8),
            _buildDepositOption('Futures', Icons.timeline),
            const SizedBox(width: 8),
            _buildDepositOption('More', Icons.more_horiz),
          ],
        ),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _buildDepositOption(String title, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    if (_isDataLoading) {
      return _buildRewardSkeleton();
    }

    if (reward.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rewards',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      reward['image'] ?? 'https://www.tcisscan.com/assets/images/logo.png',
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.qr_code_scanner, color: Colors.black, size: 48);
                      },
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward['name'] ?? 'Reward',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Ends in: ${reward['period'] ?? 0}D',
                              style: const TextStyle(
                                color: Colors.grey,
                                backgroundColor: Colors.tealAccent,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Hot',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total reward',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatTotalBalance(reward['reward']?.toDouble() ?? 0.0)} ${reward['name']?.toString().split(' ').first ?? ''}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Join now',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      '2m',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.person, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${reward['totalParticipates']?.toString() ?? '0'}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRewardSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rewards',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 24,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    Container(
                      width: 100,
                      height: 36,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNewUsersChoiceSection() {
    if (_isDataLoading) {
      return _buildUserChoicesSkeleton();
    }

    if (userChoices.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "New users' choice",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: userChoices.length,
              itemBuilder: (context, index) {
                final choice = userChoices[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCryptoCard(
                    choice['name'] ?? '',
                    choice['change']?.toString() ?? '0',
                    '\$${formatTotalBalance(choice['price']) ?? '0'}',
                    choice['image'] ?? 'https://www.tcisscan.com/assets/images/logo.png',
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserChoicesSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 24,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 14,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(String symbol, String change, String price, String imageUrl) {
    final isPositive = change.startsWith('-') ? false : true;

    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                size: 28,
                color: Colors.red,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 4),
          Text(
            symbol,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isPositive ? '+' : ''}$change%',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 14,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturesSection() {
    if (_isDataLoading) {
      return _buildFuturesSkeleton();
    }

    if (futures.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Futures',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: futures.length,
              itemBuilder: (context, index) {
                final future = futures[index];
                final tag = future['tag']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFutureCard(
                    pair: future['name'] ?? '',
                    price: future['price']?.toDouble() ?? 0.0,
                    changePercent: future['change']?.toDouble() ?? 0.0,
                    timeAgo: '${index + 1}m ago',
                    user: '0x${index + 1}a***${index + 2}${index + 3}',
                    isNew: tag.isNotEmpty, // Show badge if tag exists
                    tag: tag, // Pass the tag text to display
                    path: future['image'] ?? 'https://www.tcisscan.com/assets/images/logo.png',
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFuturesSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 24,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 80,
                              height: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 120,
                          height: 24,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 40,
                              height: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 14,
                              height: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 14,
                          color: Colors.grey[400],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFutureCard({
    required String pair,
    required double price,
    required double changePercent,
    required String timeAgo,
    required String user,
    required bool isNew,
    String tag = '', // Add this parameter
    required String path,
  }) {
    final isPositive = changePercent >= 0;

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    pair,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isNew) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.isNotEmpty ? tag : 'New', // Display the tag text or 'New' as fallback
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatTotalBalance(price),
                style: TextStyle(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.person_outline, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    user,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2FBCF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Go long',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFC4C7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Go short',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHold2EarnSection() {
    if (_isDataLoading) {
      return _buildHold2EarnSkeleton();
    }

    if (hold2Earns.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hold2Earn',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hold2Earns.length,
              itemBuilder: (context, index) {
                final earn = hold2Earns[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildEarnCard(
                    title: earn['name'] ?? '',
                    apy: earn['apy']?.toStringAsFixed(2) ?? '0',
                    subtitle: earn['subName'] ?? 'Stablecoin Earn',
                    badge: earn['additionalApy']?.toDouble() > 0 ? '+${earn['additionalApy']?.toStringAsFixed(0)}% APY' : null,
                    imageUrl: earn['image'] ?? 'https://www.tcisscan.com/assets/images/logo.png',
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHold2EarnSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 24,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              color: Colors.grey[400],
                            ),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 14,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEarnCard({
    required String title,
    required String apy,
    required String subtitle,
    String? badge,
    String imageUrl = 'https://www.tcisscan.com/assets/images/logo.png',
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                imageUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    size: 28,
                    color: Colors.red,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$apy% APY',
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCenterSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 8),
              _buildHelpCard('Set up TCIS Wallet', Icons.help_outline),
              const SizedBox(width: 8),
              _buildHelpCard('Buy your first crypto', Icons.support_agent),
              const SizedBox(width: 8),
              _buildHelpCard('Make your first trade', Icons.add_circle),
              const SizedBox(width: 8),
              _buildHelpCard('Basic functions', Icons.access_alarm_sharp),
              const SizedBox(width: 8),
              _buildHelpCard('Swap trading', Icons.traffic_rounded),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _buildHelpCard(String title, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    if (_isDataLoading) {
      return _buildTrendingSkeleton();
    }

    if (trendings.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trendings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trendings.length,
              itemBuilder: (context, index) {
                final trending = trendings[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildTrendingCardCard(
                    trending['name'] ?? '',
                    trending['image'] ?? 'https://www.tcisscan.com/assets/images/logo.png',
                    trending['change']?.toDouble() ?? 0.0,
                    trending['price']?.toDouble() ?? 0.0,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrendingSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 24,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 14,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrendingCardCard(String title, String path, double percent, double price) {
    final isPositive = percent >= 0;
    final percentText = '${isPositive ? '+' : ''}${percent.toStringAsFixed(2)}%';
    final priceText = '\$${price.toStringAsFixed(5)}';

    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            path,
            width: 20,
            height: 20,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                size: 20,
                color: Colors.red,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentText,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            priceText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsButton() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AccountMenuScreen(walletAddress: walletAddress, displayName: accountName, rewards: rewards),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      icon: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.apps,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}