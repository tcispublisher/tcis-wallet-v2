import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import '../../../services/apiService.dart';
import '../profile/sendConfirmationScreen.dart';

class SendScreen extends StatefulWidget {
  final Map<String, dynamic> token;
  final String? symbol;
  final double? balance;
  final double? price;
  final String? image;
  final String? walletAddress;
  final String? network;

  const SendScreen({
    super.key,
    required this.token,
    this.symbol,
    this.balance,
    this.price,
    this.image,
    this.walletAddress,
    this.network
  });


  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  double _gasFee = 0.0001;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSend() {
    if (_addressController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Recipient wallet address cannot be empty.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar(
        "Error",
        "Please enter a valid amount.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    double balance =
        double.tryParse(widget.balance.toString()) ?? 0;
    if (amount > balance) {
      Get.snackbar(
        "Error",
        "The transfer amount exceeds your available balance, excluding fees.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (widget.symbol == "BTC") {
      if (amount < 0.00002) {
        Get.snackbar(
          "Error",
          "Minimum transaction of Bitcoin is 0.00002 BTC.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (widget.symbol == "ETH") {
      if (amount < 0.001) {
        Get.snackbar(
          "Error",
          "Minimum transaction of Ethereum is 0.001 ETH.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (widget.symbol == "EFT") {
      if (amount < 1) {
        Get.snackbar(
          "Error",
          "Minimum transaction of TCIS Token is 1.00 TCIS.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (widget.symbol == "USDT") {
      if (amount < 1) {
        Get.snackbar(
          "Error",
          "Minimum transaction of Tether USDT is 1.00 USDT.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (widget.symbol == "XRP") {
      if (amount < 1) {
        Get.snackbar(
          "Error",
          "Minimum transaction of Ripple is 1.00 XRP.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (amount + 1 >= balance) {
        Get.snackbar(
          "Error",
          "The XRP wallet must maintain a minimum of 1 XRP after a successful transaction..",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (widget.symbol == "TON") {
      if (amount < 1) {
        Get.snackbar(
          "Error",
          "Minimum transaction of TON Coin is 1.00 TON.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (widget.symbol == "BNB") {
      if (amount < 0.003) {
        Get.snackbar(
          "Error",
          "Minimum transaction of Binance Coin is 0.003 BNB.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendConfirmationScreen(
            network: widget.network!,
            symbol: widget.symbol!,
            token: widget.token,
            address: _addressController.text,
            amount: double.parse(_amountController.text),
            gasFee: _gasFee,
            memo: _memoController.text
          ),
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
          'Send',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [

        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Network',
                  style: TextStyle(color: Colors.black, fontSize: 14),

                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey, // Gray border color
                      width: 1.0, // Border thickness
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
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
                          const SizedBox(width: 8),
                          Text(
                            widget.token['name'],
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        'Network: ${widget.network}',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'To',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    focusColor: Colors.black,
                    hintText: 'Receiving address',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Border radius set to 10 units
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border color
                        width: 1.0, // Border thickness
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Consistent border radius
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Consistent border radius
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border when focused
                        width: 1.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a receiving address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Amount',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixText: widget.symbol, // Always display USDT
                    suffixStyle: const TextStyle(color: Colors.black), // Always black
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border when focused
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.tealAccent),
                      onPressed: () {},
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Balance: ${widget.balance}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Memo',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    hintText: 'Memo is required when transfer XRP, TON, ...',
                    hintStyle: const TextStyle(color: Colors.redAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Gray border when focused
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.tealAccent),
                      onPressed: () {},
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      if (widget.symbol == "TON" || widget.symbol == "XRP") {
                        return 'Memo is required for ${widget
                            .symbol} transaction';
                      }
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _NonLeadingZeroFormatter(),
                  ],

                ),
                const SizedBox(height: 20),
                const Text(
                  'Gas Fee',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey, // Gray border color
                      width: 1.0, // Border thickness
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('<0.0001 ${widget.symbol}', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const Text('0.08', style: TextStyle(color: Colors.black, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: _onSend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
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
      ),
    );
  }
}

class _NonLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;

    if (newText.isEmpty) return newValue;

    // Chỉ cho "0" nếu chỉ nhập 1 chữ số
    if (newText.length == 1 && newText == '0') return newValue;

    // Nếu có nhiều ký tự mà bắt đầu bằng "0" thì loại bỏ
    if (newText.length > 1 && newText.startsWith('0')) {
      return TextEditingValue(
        text: newText.replaceFirst(RegExp(r'^0+'), ''),
        selection: TextSelection.collapsed(offset: newText.length - 1),
      );
    }

    return newValue;
  }
}
