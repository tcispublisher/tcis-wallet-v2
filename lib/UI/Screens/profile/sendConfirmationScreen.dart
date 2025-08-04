import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import '../../../services/apiService.dart';
import '../../common_widgets/bottomRectangularbtn.dart';
import '../sendScreens/conformationScreen.dart';

class SendConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> token;
  final String network;
  final String symbol;
  final String address;
  final double amount;
  final double gasFee;
  final String memo;

  const SendConfirmationScreen({
    super.key,
    required this.token,
    required this.address,
    required this.amount,
    required this.gasFee,
    required this.memo,
    required this.network,
    required this.symbol,
  });

  @override
  State<SendConfirmationScreen> createState() => _SendConfirmationScreenState();
}

class _SendConfirmationScreenState extends State<SendConfirmationScreen> {
  String _shortenAddress(String address) {
    if (address.length <= 10) return address; // No need to shorten if already short
    return '${address.substring(0, 6)}...${address.substring(address.length - 5)}';
  }

  Widget _showConfirmationDialog(
      BuildContext context,
      String network,
      double amount,
      String symbol,
      String walletAddressReceiver,
      String memo
      ) {
    // Format the amount with proper decimal places
    final formattedAmount = NumberFormat.currency(
      decimalDigits: 4,
      symbol: '',
    ).format(amount);

    return Container(
      height: Get.height * 0.8,
      width: Get.width,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Confirm Transfer",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: "dmsans",
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: "dmsans",
                      ),
                      children: [
                        const TextSpan(text: "You are about to transfer "),
                        TextSpan(
                          text: "$formattedAmount $symbol",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const TextSpan(text: " to:\n"),
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SelectableText(
                              walletAddressReceiver,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                fontFamily: "monospace",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (memo.isNotEmpty) ...[
                          const TextSpan(text: "\nMemo: "),
                          TextSpan(
                            text: memo,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "If you transfer to the wrong network or address, we cannot recover your assets.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.redAccent,
                      fontFamily: "dmsans",
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BottomRectangularBtn(
                  onlyBorder: true,
                  color: Colors.transparent,
                  onTapFunc: () => Get.back(),
                  btnTitle: "Cancel",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BottomRectangularBtn(
                  onTapFunc: () {
                    Navigator.pop(context); // Close confirmation dialog
                    _sendTransaction(
                        context,
                        network,
                        walletAddressReceiver,
                        amount.toString(),
                        symbol,
                        int.tryParse(memo) ?? 0
                    );
                  },
                  btnTitle: "Confirm",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendTransaction(
      BuildContext context,
      String network,
      String walletAddressReceiver,
      String amount,
      String symbol,
      int memo,
      ) async {
    // Show loading dialog using GetX to avoid context issues
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.tealAccent,
            ),
            const SizedBox(height: 20),
            Text(
              'Processing transaction...',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? privateKey = prefs.getString('privateKey');
      String? savedWallet = prefs.getString('walletAddress');

      if (privateKey == null || savedWallet == null) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          "Error",
          "Wallet not found",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      String result;
      double amountValue = double.parse(amount);

      if (symbol == "BNB") {
        result = await sendBNB(walletAddressReceiver, amountValue, privateKey);
      } else if (symbol == "USDT") {
        result =
        await sendUSDTBEP20(walletAddressReceiver, amountValue, privateKey);
      }else if (symbol == "TCIS") {
        result = await ApiService.createTransactions(
          network,
          savedWallet,
          symbol,
          walletAddressReceiver,
          amountValue,
          memo,
        );
      } else if (symbol == "BTC" || symbol == "TON" || symbol == "XRP") {
        result = await ApiService.createTransactions(
          network,
          savedWallet,
          symbol,
          walletAddressReceiver,
          amountValue,
          memo,
        );
      } else {
        if (network == "Binance Smart Chain") {
          result = await ApiService.createTransactions(
            network,
            savedWallet,
            symbol,
            walletAddressReceiver,
            amountValue,
            memo,
          );
        } else {
          result = "Unsupported token";
        }
      }

      Get.back(); // Close loading dialog

      if (result.contains("failed") || result.contains("Unsupported")) {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.85), // More opaque background
                border: Border.all(color: Colors.red[100]!.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outlined,
                      color: Color(0xFFD32F2F), // Deeper red
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text("Transaction Failed",
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50]!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          result,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: 120,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFD32F2F),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: Text("OK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.85), // Tăng độ mờ nền lên 85%
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                      color: Color(0xFF008080),
                      size: 48,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Transaction sent successfully!",
                      style: TextStyle(
                        color: Colors.black, // Chuyển sang màu đen cho rõ ràng
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        "Result: ${result}", // Giữ nguyên định dạng xuống dòng
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontFamily: 'RobotoMono', // Font monospace cho địa chỉ
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 120,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF008080),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          Get.until((route) => route.isFirst);
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.dialog(
        AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirm',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Confirmation',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Token', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Row(
                          children: [
                            Text(widget.token['name'], style: const TextStyle(color: Colors.black, fontSize: 14)),
                            const SizedBox(width: 8),
                            Image.network(
                              widget.token['icon'], // Assuming token['icon'] contains an HTTPS URL like 'https://example.com/image.png'
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Handle errors (e.g., image fails to load)
                                return const Icon(
                                  Icons.error,
                                  size: 24,
                                  color: Colors.red,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                // Show a loading indicator while the image is loading
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('To', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Expanded(
                          child:
                          Text(
                            _shortenAddress(widget.address),
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text('${widget.amount} ${widget.token['name']}', style: const TextStyle(color: Colors.black, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gas Fee', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text('<${widget.gasFee} ${widget.token['name']} (\$0.01)', style: const TextStyle(color: Colors.black, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child:
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => _showConfirmationDialog(
                          context,
                          widget.network,
                          widget.amount,
                          widget.symbol,
                          widget.address,
                          widget.memo,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Confirm Send',
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
      ),
    );
  }
}

Future<String> sendBNB(String receiver, double amount, String privateKey) async {
  try {
    // Setup Web3 client with the Binance Smart Chain RPC URL
    final client = Web3Client("https://bsc-dataseed.binance.org/", http.Client());

    // Create credentials from the private key
    final credentials = EthPrivateKey.fromHex('0x' + privateKey);

    // Get the nonce (transaction count)
    final nonce = await client.getTransactionCount(credentials.address);

    // Convert the amount to Wei (BNB is 18 decimals)
    final weiAmount = BigInt.parse((amount * 1e18).toStringAsFixed(0));

    // Set gas price and gas limit
    final gasPrice = await client.getGasPrice();
    final gasLimit = 21000; // Standard gas for sending BNB

    // Check sender's balance
    final balance = await client.getBalance(credentials.address);
    final bnbBalance = balance.getInWei;

    // Calculate the total transaction cost (amount + gas)
    final gasCost = gasPrice.getInWei * BigInt.from(gasLimit);
    final totalCost = weiAmount + gasCost;

    // Check if balance is sufficient
    if (bnbBalance < totalCost) {
      return "Insufficient funds for amount + gas cost";
    }

    // Convert BigInt to EtherAmount
    EtherAmount amountInEther = EtherAmount.inWei(weiAmount);

    // Build the transaction
    final transaction = Transaction(
      to: EthereumAddress.fromHex(receiver),
      value: amountInEther, // Using EtherAmount here
      gasPrice: gasPrice,
      maxGas: gasLimit,
    );

    // Send the transaction
    final transactionHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: 56, // BSC Chain ID
    );

    return transactionHash; // Return the transaction hash
  } catch (e) {
    return "Transaction failed: $e"; // Return the error message if something goes wrong
  }
}

Future<String> sendUSDTBEP20(String receiver, double amount, String privateKey) async {
  const String MAINNET_URL = "https://bsc-dataseed.binance.org/";
  const String USDTBEP20_CONTRACT_ADDRESS = "0x55d398326f99059fF775485246999027B3197955"; // USDT contract on BSC

  try {
    // Set up Web3 client and credentials
    final client = Web3Client(MAINNET_URL, http.Client());
    final credentials = EthPrivateKey.fromHex('0x' + privateKey);

    // Convert amount to token's base unit (USDT has 18 decimals, so multiply by 10^6)
    final tokenAmount = BigInt.parse((amount * 1e18).toStringAsFixed(0));

    // Define the ABI for the ERC-20 contract methods we will call
    String abi = '''
    [
      {
        "constant": true,
        "inputs": [{"name": "owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "", "type": "uint256"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [{"name": "recipient", "type": "address"}, {"name": "amount", "type": "uint256"}],
        "name": "transfer",
        "outputs": [{"name": "", "type": "bool"}],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]
    ''';

    // Load the contract
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, 'USDT'),
      EthereumAddress.fromHex(USDTBEP20_CONTRACT_ADDRESS),
    );

    // Get the balance of the sender
    final balanceFunction = contract.function('balanceOf');
    final balance = await client.call(
      contract: contract,
      function: balanceFunction,
      params: [credentials.address],
    );
    final senderBalance = balance[0] as BigInt;

    // Check if the sender has enough balance to send the specified amount
    if (senderBalance.compareTo(tokenAmount) < 0) {
      return "Insufficient USDT balance.";
    }

    // Get the latest nonce for the transaction
    final nonce = await client.getTransactionCount(credentials.address);

    // Define gas price and gas limit for the transaction
    final gasPrice = await client.getGasPrice();
    final gasLimit = 60000; // Gas limit for ERC-20 transfers

    // Create the transaction to send USDT
    final transferFunction = contract.function('transfer');
    final transaction = Transaction.callContract(
      contract: contract,
      function: transferFunction,
      parameters: [
        EthereumAddress.fromHex(receiver), // Recipient's address
        tokenAmount, // Amount of USDT to send
      ],
      gasPrice: gasPrice,
      maxGas: gasLimit,
    );

    // Send the transaction
    final transactionHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: 56, // BSC Chain ID
    );

    return transactionHash; // Return the transaction hash
  } catch (e) {
    return "Transaction failed: $e"; // Return the error message if something goes wrong
  }
}