import 'dart:convert';

import 'package:crypto_wallet/UI/Screens/profile/tokenDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallet_provider.dart';
import '../../../services/apiService.dart';
import 'accountMenuScreen.dart';

class TokenListSkeleton extends StatelessWidget {
  const TokenListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Show 5 skeleton items
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300], // Using grey shade 300
            radius: 16,
          ),
          title: Container(
            height: 16,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 16,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BalanceTextSkeleton extends StatelessWidget {
  const BalanceTextSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 32,
        width: 100, // Vừa với text kiểu "$12,345"
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.only(bottom: 8),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String walletAddress = '';
  String chainWalletAddress = '';
  String privateKey = '';
  String accountName = '';
  double rewards = 0;
  var isVisible = false.obs;
  List coins = [];
  bool _isLoading = true; // Add this loading state
  bool _isInitialLoading = true; // Track initial load only
  bool _isRefreshing = false; // Track refresh state
  String selectedChain = 'TCIS Chain';

  bool _isPanelOpen = false;
  final GlobalKey _panelKey = GlobalKey(); // Thêm key cho panel

  double getTotalBalance(List coins) {
    return coins.fold(0.0, (total, coin) {
      double amount = double.tryParse(coin['amount'].toString()) ?? 0.0;
      double price = double.tryParse(coin['price'].toString()) ?? 0.0;
      return total + (amount * price);
    });
  }

  void _copyToClipboard(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $selectedChain wallet address to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String formatBalance(String balance) {
    try {
      double value = double.parse(balance);

      if (value == 0) {
        return "0.00";
      }

      if (value < 0.0001) {
        return NumberFormat("0.0000000", "en_US").format(value);
      }

      return NumberFormat("#,##0.######", "en_US").format(value);
    } catch (e) {
      return "Invalid balance";
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

  String formatNumber(double value) {
    final NumberFormat format = NumberFormat.currency(
      locale: 'en_US',
      symbol: '', // Không thêm đơn vị tiền
      decimalDigits: value == value.roundToDouble()
          ? 0
          : ((value * 10).roundToDouble() == value * 10)
          ? 1
          : 2,
    );

    return format.format(value).trim();
  }

  String formatAmount(double value, String symbol) {
    int maxDecimals;

    switch (symbol.toUpperCase()) {
      case 'BTC':
        maxDecimals = 6;
        break;
      case 'ETH':
        maxDecimals = 4;
        break;
      case 'BNB':
        maxDecimals = 3;
        break;
      default:
      // Mặc định: nếu là số nguyên thì 0, nếu x.x0 thì 1, còn lại 2
        if (value == value.roundToDouble()) {
          maxDecimals = 0;
        } else if ((value * 10).roundToDouble() == value * 10) {
          maxDecimals = 1;
        } else {
          maxDecimals = 2;
        }
        break;
    }

    final NumberFormat format = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: maxDecimals,
    );

    return format.format(value).trim();
  }

  // Refresh handler to regenerate tokenList
  Future<void> _handleRefresh() async {
    await _loadWalletData(isRefresh: true); // Pass isRefresh flag
  }

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _showTokenInputForm() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return TokenInputFormDialog(
          onAddToken: _loadWalletData,
          walletAddress: walletAddress,
        );
      },
    );
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

      // Pass selectedChain to the API call to fetch tokens for the specific chain
      dynamic response = await ApiService.fetchChainStatistic(savedWalletAddress, chain: selectedChain);

      setState(() {
        coins = response;
        rewards = coins.isNotEmpty ? coins[0]['rewards'] : 0.0;
        accountName = coins.isNotEmpty ? coins[0]['displayName'] : '';
        walletAddress = savedWalletAddress;
        chainWalletAddress = coins.isNotEmpty ? coins[0]['walletAddress'] : '';
        _isInitialLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
        _isRefreshing = false;
        coins = [];
      });
      Get.snackbar(
        'Error fetching data: $e',
        '',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán tổng balance
    final totalBalance = getTotalBalance(coins);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            // Text center, cách top 20
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Căn giữa nội dung trong Center
                    children: [
                      Text(
                        selectedChain, // render tên chain
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        tooltip: 'Copy',
                        onPressed: () {
                          _copyToClipboard(chainWalletAddress);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions bên phải
            Positioned(
              right: 0,
              top: 40,
              bottom: 0,
              child: Row(
                children: [
                  _buildChainSelector(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Colors.white,
          backgroundColor: Colors.grey[900],
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                if (_isInitialLoading && coins.isEmpty)
                  const BalanceTextSkeleton()
                else
                  Center(
                    child: Text(
                      '\$${formatTotalBalance(totalBalance)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                const SizedBox(height: 60),
                _buildFeatureCards(),
                const SizedBox(height: 20),
                _buildTokenListHeader(),
                _buildTokenList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChainSelector() {
    List<String> chains = [
      'TCIS Chain',
      'Binance Smart Chain',
      'Bitcoin Blockchain',
      'Ethereum Chain',
      'The Open Network',
      'Ripple Ledger',
    ];

    return PopupMenuButton<String>(
      onSelected: (String chain) async {
        setState(() {
          selectedChain = chain;
          _isInitialLoading = true; // Show loading state when chain changes
          coins = []; // Clear current coins to show skeleton
        });
        await _loadWalletData(); // Fetch new data for the selected chain
        setState(() {
          final match = coins.firstWhere(
                (item) => item['network']?.toString().trim().toLowerCase() == selectedChain.trim().toLowerCase(),
            orElse: () => null,
          );
          chainWalletAddress = match != null ? match['walletAddress'] : '';
        });
      },
      itemBuilder: (BuildContext context) {
        return chains.map((String chain) {
          return PopupMenuItem<String>(
            value: chain,
            child: Text(chain),
          );
        }).toList();
      },
      icon: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.lightBlueAccent,
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

  Widget _buildFeatureCards() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFeatureCard(
            title: 'Earn',
            action: 'Stake now',
            subtitle: 'Up to 6.65% APY',
            icon: Icons.savings,
          ),
          _buildFeatureCard(
            title: 'GetGas',
            action: 'Deposit now',
            subtitle: 'Pay gas with USDT',
            icon: Icons.local_gas_station,
          ),
          _buildFeatureCard(
            title: 'Card',
            action: 'Activate now',
            subtitle: 'Spend it like fiat',
            icon: Icons.credit_card,
          ),
          _buildFeatureCard(
            title: 'Referral',
            action: 'Invite friends',
            subtitle: 'Earn rewards together',
            icon: Icons.group,
          ),
          _buildFeatureCard(
            title: 'Backup',
            action: 'Secure wallet',
            subtitle: 'Save your seed',
            icon: Icons.lock,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String action,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Icon(icon, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                action,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTokenListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tokens \$${formatTotalBalance(getTotalBalance(coins))}',
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: _showTokenInputForm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenList() {
    if (_isInitialLoading && coins.isEmpty) {
      return const TokenListSkeleton(); // Only show skeleton on initial load when no data
    }

    return ListView.builder(
      itemCount: coins.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final amount = double.tryParse(coins[index]['amount'].toString()) ?? 0.0;
        final price = double.tryParse(coins[index]['price'].toString()) ?? 0.0;
        final usdValue = amount * price;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child:
            Image.network(
              coins[index]['image'],
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error,
                size: 32,
                color: Colors.red,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                return loadingProgress == null
                    ? child
                    : const CircularProgressIndicator();
              },
            ),
          ),
          title: Text(
            '${coins[index]['des']} (${coins[index]['symbol']})',
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '\$${formatTotalBalance(price)}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(amount, coins[index]['symbol']),
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                '\$${formatTotalBalance(usdValue)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TokenDetailScreen(
                  token: {
                    'walletReceive': coins[index]['walletAddress'],
                    'name': coins[index]['symbol'], // or whatever your token name is
                    'icon': coins[index]['image'], // the URL for the token icon
                    'amount': coins[index]['amount'],
                    'price': coins[index]['price'],
                    'network': coins[index]['contract'],
                    'contract': coins[index]['network'],
                    'marketCap': coins[index]['marketCap'],
                    'currentSupply': coins[index]['currentSupply'],
                    'maxSupply': coins[index]['maxSupply'],
                    'liquidity': coins[index]['liquidity'],
                    'officialWebsite': coins[index]['officialWebsite'],
                    'whitePaper': coins[index]['whitePaper'],
                    'explorer': coins[index]['explorer']
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TokenInputFormDialog extends StatefulWidget {
  final String walletAddress;
  final VoidCallback onAddToken;

  const TokenInputFormDialog({Key? key, required this.onAddToken, required this.walletAddress})
      : super(key: key);

  @override
  _TokenInputFormDialogState createState() => _TokenInputFormDialogState();
}

class _TokenInputFormDialogState extends State<TokenInputFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contractAddressController = TextEditingController();
  final _tokenNameController = TextEditingController();
  final _tokenSymbolController = TextEditingController();
  final _tokenDecimalsController = TextEditingController();

  bool _isFetchingTokenInfo = false;
  bool _tokenInfoFetchedSuccessfully = false; // Cờ để biết thông tin token đã được lấy thành công chưa
  bool _isContractAddressFieldEnabled = true; // Cờ để kiểm soát trạng thái enable/disable của ô contract

  @override
  void dispose() {
    _contractAddressController.dispose();
    _tokenNameController.dispose();
    _tokenSymbolController.dispose();
    _tokenDecimalsController.dispose();
    super.dispose();
  }

  void _resetTokenInfoFields() {
    _tokenNameController.text = '';
    _tokenSymbolController.text = '';
    _tokenDecimalsController.text = '';
    _tokenInfoFetchedSuccessfully = false;
    _isContractAddressFieldEnabled = true; // Cho phép nhập lại contract address
    Navigator.pop(context);
  }

  Future<void> processToken() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contractAddress = _contractAddressController.text.trim();
    setState(() {
      _isFetchingTokenInfo = true;
      _tokenInfoFetchedSuccessfully = false;
      _tokenNameController.text = '';
      _tokenSymbolController.text = '';
      _tokenDecimalsController.text = '';
      _isContractAddressFieldEnabled = false;
    });

    try {
      dynamic rawResult = await ApiService.validateContract(widget.walletAddress, contractAddress);
      print(rawResult);

      // Check if rawResult is a string and matches specific error messages
      if (rawResult is String) {
        String errorMessage = rawResult;
        if (errorMessage == "This wallet address is not existed on the system." ||
            errorMessage == "Can not add default smart contract of USDT-BEP20." ||
            errorMessage == "This token has already been added to this wallet.") {
          if (mounted) {
            Get.snackbar(
              errorMessage,
              "",
              backgroundColor: Colors.redAccent,
              colorText: Colors.black,
              margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.TOP,
            );
            setState(() {
              _isFetchingTokenInfo = false;
              _tokenInfoFetchedSuccessfully = false;
              _isContractAddressFieldEnabled = true;
            });
          }
        }
      }

      // Handle map or JSON response
      Map<String, dynamic> tokenData = json.decode(rawResult) as Map<String, dynamic>;

      if (mounted) {
        bool isDataUnknown = tokenData['TokenName']?.toString().toLowerCase() == 'unknown' ||
            tokenData['TokenSymbol']?.toString().toLowerCase() == 'unknown' ||
            tokenData['TokenDecimals']?.toString().toLowerCase() == 'unknown';

        if (isDataUnknown || tokenData['TokenName'] == null) {
          setState(() {
            _isFetchingTokenInfo = false;
            _tokenInfoFetchedSuccessfully = false;
            _isContractAddressFieldEnabled = true;
          });
          Get.snackbar(
            "Smart contract is not found or can not be added.",
            "",
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
            margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        } else {
          setState(() {
            _tokenNameController.text = tokenData['TokenName']?.toString() ?? '';
            _tokenSymbolController.text = tokenData['TokenSymbol']?.toString() ?? '';
            _tokenDecimalsController.text = tokenData['TokenDecimals']?.toString() ?? '';
            _isFetchingTokenInfo = false;
            _tokenInfoFetchedSuccessfully = true;
            _isContractAddressFieldEnabled = false;
          });
          Get.snackbar(
            "Fetch data from smart contract successful.",
            "",
            backgroundColor: Colors.greenAccent,
            colorText: Colors.black,
            margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingTokenInfo = false;
          _tokenInfoFetchedSuccessfully = false;
          _isContractAddressFieldEnabled = true;
        });
      }
    }
  }

  Future<void> addToken() async {
    // Nút Save chỉ được nhấn khi _tokenInfoFetchedSuccessfully là true
    if (!_tokenInfoFetchedSuccessfully) {
      Get.snackbar(
        "Smart contract should be validated before adding.",
        "",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contractAddress = _contractAddressController.text.trim();

    try {
      dynamic result = await ApiService.addToken(widget.walletAddress, contractAddress);

      Get.snackbar(
        result.toString().toLowerCase().contains("success") || result.toString().toLowerCase().contains("thành công")
            ? result.toString()
            : result.toString(),
        "",
        backgroundColor: result.toString().toLowerCase().contains("success") ||
            result.toString().toLowerCase().contains("thành công")
            ? Colors.greenAccent
            : Colors.redAccent,
        colorText: result.toString().toLowerCase().contains("success") ||
            result.toString().toLowerCase().contains("thành công")
            ? Colors.black
            : Colors.white,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );

      if (result.toString().toLowerCase().contains("successful.") ||
          result.toString().toLowerCase().contains("thành công")) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onAddToken();
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error adding token: $e',
        "",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate 80% of screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 1.2;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minWidth: dialogWidth,
        ),
        child: AlertDialog(
          title: const Text('Add Custom Token'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _contractAddressController,
                    enabled: _isContractAddressFieldEnabled,
                    decoration: InputDecoration(
                      labelText: 'Smart Contract Address',
                      hintText: '0x...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _isFetchingTokenInfo || !_isContractAddressFieldEnabled
                            ? null
                            : processToken,
                        icon: _isFetchingTokenInfo
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.add_circle, color: Colors.blue),
                        tooltip: _isContractAddressFieldEnabled
                            ? 'Validate smart contract'
                            : 'Smart contract info has been validated',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Smart contract must not be null';
                      }
                      if (!value.startsWith('0x') || value.length != 42) {
                        return 'Smart contract is not valid';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_tokenInfoFetchedSuccessfully) {
                        setState(() {
                          _resetTokenInfoFields();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tokenNameController,
                    decoration: const InputDecoration(
                      labelText: 'Token Name',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tokenSymbolController,
                    decoration: const InputDecoration(
                      labelText: 'Token Symbol',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tokenDecimalsController,
                    decoration: const InputDecoration(
                      labelText: 'Token Decimals',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _resetTokenInfoFields(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (_tokenInfoFetchedSuccessfully && !_isFetchingTokenInfo) ? addToken : null,
              child: const Text('Add Token'),
            ),
          ],
        ),
      ),
    );
  }
}