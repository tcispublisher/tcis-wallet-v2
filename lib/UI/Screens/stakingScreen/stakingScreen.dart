import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../services/apiService.dart';
import '../utils/MeasuredNetworkImage.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  int selectedTabIndex = 0; // mặc định là "Hot Picks 🔥"
  bool isLoading = true;
  List<dynamic> trendings = [];
  List<dynamic> tokens = [];

  String formatTotalBalance(double value) {
    try {
      if (value == 0) {
        return "0.00";
      }

      if (value < 0.0000000001) {
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

  final List<String> tabs = [
    'Hot Picks 🔥',
    'Rising Star',
    'AI Signal',
    'New',
    'Top Gainers',
    'Top Losers',
  ];

  final Map<int, String> tabToTypeMap = {
    0: 'Hot Picks',
    1: 'Rising Star',
    2: 'AI Signal',
    3: 'New',
    4: 'Top Gainers',
    5: 'Top Losers',
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await ApiService.fetchMarketInfo();

    setState(() {
      trendings = response['trendings'];
      tokens = response['tokens'];
      isLoading = false;
    });
  }

  List<dynamic> _getFilteredTokens() {
    if (isLoading || tokens.isEmpty) return [];

    final type = tabToTypeMap[selectedTabIndex];
    return tokens.where((token) => token['type'] == type).toList();
  }

  Color _getChangeColor(double change) {
    return change >= 0 ? Colors.tealAccent : Colors.pinkAccent;
  }

  String _formatNumber(double num) {
    if (num >= 1000000000) {
      return '\$${(num / 1000000000).toStringAsFixed(1)}B';
    } else if (num >= 1000000) {
      return '\$${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '\$${(num / 1000).toStringAsFixed(1)}K';
    }
    return '\$${num.toStringAsFixed(4)}';
  }

  String _formatChange(double change) {
    final formatter = NumberFormat("#,##0.00", "en_US"); // phần ngàn, 2 chữ số sau dấu thập phân
    final formatted = formatter.format(change.abs()); // dùng abs để bỏ dấu trừ, thêm thủ công sau
    return '${change >= 0 ? '+' : '-'}$formatted%';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTokens = _getFilteredTokens();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Discover top memecoins!',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Swipeable Trending Cards
              SizedBox(
                height: 140,
                child: isLoading
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.white,
                            ),
                            const Spacer(),
                            Container(
                              width: 80,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendings.length,
                  itemBuilder: (context, index) {
                    final card = trendings[index];
                    final changeColor = _getChangeColor(card['change']);
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: changeColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card['title'] ?? 'Trending',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatChange(card['change']),
                                style: TextStyle(
                                  color: changeColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                card['name'],
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              Text(
                                '${card['growth']}x',
                                style: const TextStyle(
                                    color: Colors.tealAccent, fontSize: 12),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ClipOval(
                              child:
                              MeasuredNetworkImage(
                                url: card['avatar'],
                                width: 36,
                                height: 36,
                              )
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              // Tabs row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTabIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.grey,
                                fontSize: 14,
                                fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (isSelected)
                              Container(
                                width: 20,
                                height: 2,
                                color: Colors.black,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Token List
              isLoading
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 150,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 60,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 40,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : filteredTokens.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No tokens found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTokens.length,
                itemBuilder: (context, index) {
                  final token = filteredTokens[index];
                  final changeColor = _getChangeColor(token['change']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child:
                            MeasuredNetworkImage(
                              url: token['image'],
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                token['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _formatNumber(token['marketCap']),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('|',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatNumber(token['volume']),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              if (token['description'] != '')
                                Text(
                                  token['description'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${formatTotalBalance(token['price'])}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatChange(token['change']),
                              style: TextStyle(
                                color: changeColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}