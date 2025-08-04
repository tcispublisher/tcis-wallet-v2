import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet/providers/wallet_provider.dart';
import 'package:crypto_wallet/services/apiService.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/MeasuredNetworkImage.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  TextEditingController fromAmountController = TextEditingController();
  TextEditingController toAmountController = TextEditingController();
  bool isChangingFromCoin = false;
  bool isChangingToCoin = false;

  bool isLoading = true;
  bool isSwapping = false;
  bool isSnackbarVisible = false;

  List<Map<String, dynamic>> listCoins = [];
  bool listCoinsLoaded = false;

  Map<String, double> coinBalances = {};
  Map<String, double> coinPrices = {};

  // Initialize with empty defaults to avoid null issues
  Map<String, dynamic> fromCoin = {
    "image": "",
    "symbol": "",
    "chain": ""
  };

  Map<String, dynamic> toCoin = {
    "image": "",
    "symbol": "",
    "chain": ""
  };

  double fromAmount = 0;
  double toAmount = 0;
  double slippage = 1.0;
  bool isFromBalanceLoading = false;
  bool isToBalanceLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Load list of coins
      await _loadListCoins();

      // Only proceed if we have coins loaded
      if (listCoins.isNotEmpty) {
        // Update default coins from list
        _updateDefaultCoinsFromList();

        // Then load wallet data
        await _loadWalletData();
      } else {
        throw Exception("No coins available in the list");
      }
    } catch (e) {
      print("Initialization error: $e");
      if (!Get.isSnackbarOpen && !isSnackbarVisible) {
        isSnackbarVisible = true;
        Get.snackbar(
          "Initialization Error",
          "Failed to load initial data. Please try again.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          duration: const Duration(seconds: 3),
        );
        Future.delayed(const Duration(seconds: 3), () {
          isSnackbarVisible = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _updateDefaultCoinsFromList() {
    setState(() {
      // Ensure listCoins has at least one coin
      if (listCoins.isNotEmpty) {
        fromCoin = listCoins[0]; // Set first coin as fromCoin
      }

      // Ensure listCoins has at least two coins and avoid selecting the same coin
      if (listCoins.length > 1 && listCoins[1]['symbol'] != fromCoin['symbol']) {
        toCoin = listCoins[1]; // Set second coin as toCoin
      } else if (listCoins.length > 1 && listCoins[0]['symbol'] == listCoins[1]['symbol']) {
        // If second coin is the same as the first, try to find another different coin
        for (var coin in listCoins) {
          if (coin['symbol'] != fromCoin['symbol']) {
            toCoin = coin;
            break;
          }
        }
      } else if (listCoins.length == 1) {
        // Fallback if only one coin is available
        toCoin = {
          "image": "",
          "symbol": "N/A",
          "chain": "N/A"
        };
      }
    });
  }

  @override
  void dispose() {
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadListCoins() async {
    try {
      dynamic response = await ApiService.fetchListCoins();

      if (response != null && response is List) {
        setState(() {
          listCoins = response.cast<Map<String, dynamic>>();
          listCoinsLoaded = true;
        });
      } else {
        throw Exception("Invalid coins data format");
      }
    } catch (e) {
      print("Error loading coins list: $e");
      throw e;
    }
  }

  Future<void> _loadWalletData() async {
    try {
      setState(() {
        isFromBalanceLoading = true;
        isToBalanceLoading = true;
      });

      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.loadPrivateKey();

      String? savedWalletAddress = await walletProvider.getWalletAddress();
      if (savedWalletAddress == null) {
        throw Exception("Can't get the wallet address");
      }

      await _loadCoinData(savedWalletAddress, fromCoin['symbol'], isFrom: true);
      await _loadCoinData(savedWalletAddress, toCoin['symbol'], isFrom: false);
    } catch (e) {
      print("Error in _loadWalletData: $e");
      throw e;
    } finally {
      if (mounted) {
        setState(() {
          isFromBalanceLoading = false;
          isToBalanceLoading = false;
        });
      }
    }
  }

  Future<void> _loadCoinData(String walletAddress, String symbol, {required bool isFrom}) async {
    try {
      dynamic response = await ApiService.fetchSingStatistic(walletAddress, symbol);

      print(response);
      if (response != null) {
        if (response is Map<String, dynamic>) {
          if (response['symbol'] == symbol) {
            setState(() {
              coinBalances[symbol] = double.tryParse(response['amount'].toString()) ?? 0;
              coinPrices[symbol] = double.tryParse(response['price'].toString()) ?? 0;
            });
          }
        }
        else if (response is List) {
          for (var token in response) {
            if (token['symbol'] == symbol) {
              setState(() {
                coinBalances[symbol] = double.tryParse(token['amount'].toString()) ?? 0;
                coinPrices[symbol] = double.tryParse(token['price'].toString()) ?? 0;
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      print("Error loading coin data: $e");
    }
  }

  String formatBalance(double balance) {
    try {
      if (balance == 0) return "0.00";
      if (balance < 0.0001) return NumberFormat("0.0000000", "en_US").format(balance);
      return NumberFormat("#,##0.######", "en_US").format(balance);
    } catch (e) {
      return "Invalid balance";
    }
  }

  void _handleSwitchCoins() {
    if (fromCoin['symbol'] == toCoin['symbol']) return;

    setState(() {
      final temp = fromCoin;
      fromCoin = toCoin;
      toCoin = temp;

      fromAmount = 0;
      toAmount = 0;

      fromAmountController.clear();
      toAmountController.clear();

      final tempLoading = isFromBalanceLoading;
      isFromBalanceLoading = isToBalanceLoading;
      isToBalanceLoading = tempLoading;
    });
  }

  void _calculateSwapAmount() {
    if (fromCoin['symbol'] == toCoin['symbol']) {
      setState(() {
        toAmount = fromAmount;
      });
      return;
    }

    double fromPrice = coinPrices[fromCoin['symbol']] ?? 0;
    double toPrice = coinPrices[toCoin['symbol']] ?? 0;

    if (fromPrice == 0 || toPrice == 0) {
      setState(() {
        toAmount = 0;
      });
      return;
    }

    setState(() {
      toAmount = (fromAmount * fromPrice) / toPrice;
      toAmountController.text = toAmount.toStringAsFixed(6);
    });
  }

  String _formatSwapRate(double rate, String toSymbol) {
    if (rate <= 0) return '0';

    final format = NumberFormat()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 10;

    String formattedRate = format.format(rate);
    return '~ ${formattedRate.replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.$'), '')}';
  }

  String _getSmallestUnit(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC': return 'Sat';
      case 'ETH': return 'Wei';
      case 'USDT': return 'Cent';
      default: return 'Min ${symbol}';
    }
  }

  double _getSmallestUnitValue(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC': return 0.00000001;
      case 'ETH': return 0.000000000000000001;
      case 'USDT': return 0.01;
      default: return 0.0001;
    }
  }

  Future<void> _selectFromCoin() async {
    if (isChangingFromCoin || isChangingToCoin) return;

    setState(() {
      isChangingFromCoin = true;
    });

    final availableCoins = listCoins.where((coin) => coin['symbol'] != toCoin['symbol']).toList();

    final selected = await showModalBottomSheet(
      context: context,
      builder: (context) => CoinSelectionSheet(coins: availableCoins),
    );

    if (selected != null && selected['symbol'] != fromCoin['symbol']) {
      setState(() {
        fromCoin = selected;
        fromAmount = 0;
        toAmount = 0;
        fromAmountController.clear();
        toAmountController.clear();
      });

      final walletAddress = await Provider.of<WalletProvider>(context, listen: false).getWalletAddress();
      if (walletAddress != null) {
        try {
          await _loadCoinData(walletAddress, fromCoin['symbol'], isFrom: true);
        } finally {
          if (mounted) {
            setState(() {
              isChangingFromCoin = false;
            });
          }
        }
      }
    } else {
      setState(() {
        isChangingFromCoin = false;
      });
    }
  }

  Future<void> _selectToCoin() async {
    if (isChangingFromCoin || isChangingToCoin) return;

    setState(() {
      isChangingToCoin = true;
    });

    final availableCoins = listCoins.where((coin) => coin['symbol'] != fromCoin['symbol']).toList();

    final selected = await showModalBottomSheet(
      context: context,
      builder: (context) => CoinSelectionSheet(coins: availableCoins),
    );

    if (selected != null && selected['symbol'] != toCoin['symbol']) {
      setState(() {
        toCoin = selected;
        toAmount = 0;
        toAmountController.clear();
      });

      final walletAddress = await Provider.of<WalletProvider>(context, listen: false).getWalletAddress();
      if (walletAddress != null) {
        try {
          await _loadCoinData(walletAddress, toCoin['symbol'], isFrom: false);
          _calculateSwapAmount();
        } finally {
          if (mounted) {
            setState(() {
              isChangingToCoin = false;
            });
          }
        }
      }
    } else {
      setState(() {
        isChangingToCoin = false;
      });
    }
  }

  void _executeSwap() async {
    if (isSwapping) return;
    setState(() => isSwapping = true);

    try {
      if (fromAmount <= 0) throw Exception("Please enter a valid amount");
      final fromBalance = coinBalances[fromCoin['symbol']] ?? 0;
      if (fromBalance < fromAmount) throw Exception("Insufficient ${fromCoin['symbol']} balance");

      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.loadPrivateKey();

      String? walletAddress = await walletProvider.getWalletAddress();
      if (walletAddress == null) throw Exception("Can't get the wallet address");

      dynamic result = await ApiService.swapExecute(
          walletAddress,
          fromAmount,
          fromCoin['symbol'],
          toCoin['symbol'],
          slippage
      );

      if (result.toString().contains("successful")) {
        if (!Get.isSnackbarOpen && !isSnackbarVisible) {
          isSnackbarVisible = true;
          Get.snackbar(
            "Swap Successful",
            result.toString(),
            backgroundColor: Colors.greenAccent,
            colorText: Colors.white,
            margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
            duration: const Duration(seconds: 3),
          );

          Future.delayed(const Duration(seconds: 3), () {
            isSnackbarVisible = false;
            fromAmount = 0;
            toAmount = 0;
            fromAmountController.clear();
            toAmountController.clear();
            _loadWalletData();
          });
        }
      } else {
        throw Exception(result.toString());
      }
    } catch (e) {
      if (!Get.isSnackbarOpen && !isSnackbarVisible) {
        isSnackbarVisible = true;
        Get.snackbar(
          "Swap Failed",
          e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        );
        Future.delayed(const Duration(seconds: 1), () {
          isSnackbarVisible = false;
        });
      }
    } finally {
      setState(() => isSwapping = false);
    }
  }

  Widget _buildTokenRow(String name, String imagePath, String value, String fiatValue,
      {bool showImpact = false, bool isFrom = false}) {
    final isLoading = isFrom ? isChangingFromCoin : isChangingToCoin;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return SizedBox(
      height: isSmallScreen ? 70 : 80,
      child: Stack(
        children: [
          Opacity(
            opacity: isLoading ? 0.5 : 1.0,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Coin icon
                  Container(
                    width: isSmallScreen ? 36 : 40,
                    height: isSmallScreen ? 36 : 40,
                    margin: EdgeInsets.only(right: screenWidth * 0.03),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: MeasuredNetworkImage(
                        url: imagePath,
                        width: isSmallScreen ? 30 : 32,
                        height: isSmallScreen ? 30 : 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Coin name and balance
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Prevent column from expanding
                      children: [
                        Flexible( // Make name row flexible
                          child: GestureDetector(
                            onTap: isLoading ? null : isFrom ? _selectFromCoin : _selectToCoin,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isSmallScreen ? 13 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black,
                                  size: isSmallScreen ? 16 : 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Flexible( // Make balance text flexible
                          child: Text(
                            "Balance: ${formatBalance(coinBalances[name] ?? 0)}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount section
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isFrom)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: screenHeight * 0.04, // Fixed height for input field
                                child: TextField(
                                  controller: fromAmountController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.end,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "0",
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,6}')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      fromAmount = double.tryParse(value) ?? 0;
                                      _calculateSwapAmount();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (fromAmountController.text.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        icon: Icon(Icons.clear, size: isSmallScreen ? 14 : 16),
                                        onPressed: isLoading ? null : () {
                                          fromAmountController.clear();
                                          setState(() {
                                            fromAmount = 0;
                                            toAmount = 0;
                                            toAmountController.clear();
                                          });
                                        },
                                      ),
                                    TextButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                                        minimumSize: MaterialStateProperty.all(Size.zero),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: isLoading ? null : () {
                                        final balance = coinBalances[fromCoin['symbol']] ?? 0;
                                        fromAmountController.text = balance.toString();
                                        setState(() {
                                          fromAmount = balance;
                                          _calculateSwapAmount();
                                        });
                                      },
                                      child: Text(
                                        "MAX",
                                        style: TextStyle(
                                          color: Colors.tealAccent,
                                          fontSize: isSmallScreen ? 11 : 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Flexible(
                                      child: Text(
                                        '\$${(fromAmount * (coinPrices[fromCoin['symbol']] ?? 0)).toStringAsFixed(2)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: isSmallScreen ? 11 : 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                toAmount == 0 ? "0" : toAmount.toStringAsFixed(6),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                '\$${(toAmount * (coinPrices[toCoin['symbol']] ?? 0)).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTokenSkeleton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
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
                  width: 100,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapDetailsSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(2, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: Colors.white,
                    ),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700; // Điều chỉnh ngưỡng theo nhu cầu

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Container(
                  width: 100,
                  height: 24,
                  color: Colors.grey[200],
                ),
                SizedBox(height: screenHeight * 0.02),

                // From token skeleton
                _buildTokenSkeleton(),
                SizedBox(height: screenHeight * 0.015),

                // To token skeleton
                _buildTokenSkeleton(),
                SizedBox(height: screenHeight * 0.03),

                // Swap details skeleton
                _buildSwapDetailsSkeleton(),
                SizedBox(height: screenHeight * 0.03),

                // Button skeleton
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    "Swap",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Token Swap Section
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      // From Token Container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        height: isSmallScreen ? screenHeight * 0.12 : screenHeight * 0.12,
                        child: _buildTokenRow(
                          fromCoin['symbol'],
                          fromCoin['image'],
                          fromAmount.toString(),
                          (fromAmount * (coinPrices[fromCoin['symbol']] ?? 0)).toString(),
                          isFrom: true,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      // To Token Container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        height: isSmallScreen ? screenHeight * 0.12 : screenHeight * 0.12,
                        child: _buildTokenRow(
                          toCoin['symbol'],
                          toCoin['image'],
                          toAmount.toString(),
                          toAmount.toString(),
                          showImpact: true,
                        ),
                      ),
                    ],
                  ),

                  Positioned(
                    top: isSmallScreen ? screenHeight * 0.11 : screenHeight * 0.095,
                    child: GestureDetector(
                      onTap: (isChangingFromCoin || isChangingToCoin || fromCoin['symbol'] == toCoin['symbol'])
                          ? null
                          : _handleSwitchCoins,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: (isChangingFromCoin || isChangingToCoin || fromCoin['symbol'] == toCoin['symbol'])
                              ? Colors.grey
                              : Colors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                        child: (isChangingFromCoin || isChangingToCoin)
                            ? SizedBox(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(
                          Icons.swap_vert,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: screenHeight * 0.03),

              // Swap Details Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Swap Details",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 20),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Divider(height: 1, color: Colors.grey),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Slippage Tolerance",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                        Text(
                          "$slippage%",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Exchange Rate",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "1 ${fromCoin['symbol']} ${_formatSwapRate(
                                (coinPrices[fromCoin['symbol']] ?? 0) / (coinPrices[toCoin['symbol']] ?? 1),
                                toCoin['symbol']
                            )} ${toCoin['symbol']}",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Swap Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSwapping || fromAmount <= 0 ? null : _executeSwap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    ),
                    child: isSwapping
                        ? SizedBox(
                      height: screenHeight * 0.025,
                      width: screenHeight * 0.025,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "Swap",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoinSelectionSheet extends StatelessWidget {
  final List<Map<String, dynamic>> coins;

  const CoinSelectionSheet({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const Text(
            "Select a token",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (coins.isEmpty)
            const Text("No available tokens to select"),
          if (coins.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: coins.length,
                itemBuilder: (context, index) {
                  final coin = coins[index];
                  return ListTile(
                    leading: MeasuredNetworkImage(
                      url: coin['image']?.isNotEmpty == true ? coin['image'] : 'assets/images/fallback.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                    title: Text(coin['symbol']),
                    subtitle: Text(coin['chain']),
                    onTap: () => Navigator.pop(context, coin),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}