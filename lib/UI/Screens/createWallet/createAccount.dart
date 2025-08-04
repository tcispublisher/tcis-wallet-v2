import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/credentials.dart';
import '../../../providers/wallet_provider.dart';
import '../../../services/apiService.dart';
import '../../common_widgets/bottomNavBar.dart';

class CreateAccountScreen extends StatefulWidget {
  final String pin;
  final bool isImport;
  final String walletAddress;
  final String publicKey;
  final String privateKey;
  final String mnemonics;

  const CreateAccountScreen({super.key,
    required this.pin,
    required this.isImport,
    required this.walletAddress,
    required this.publicKey,
    required this.privateKey,
    required this.mnemonics,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  String _errorText = '';

  @override
  void dispose() {
    accountNameController.dispose();
    referralController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (accountNameController.text
        .trim()
        .length < 4 || accountNameController.text
        .trim()
        .length > 10) {
      setState(() {
        _errorText = 'Display Name must be 4–10 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String newWalletAddress = "";
    String newPrivateKey = "";
    String newMnemonics = "";

    if (widget.isImport) {
      newWalletAddress = widget.walletAddress;
      newPrivateKey = widget.privateKey;
      newMnemonics = widget.mnemonics;
    } else {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final mnemonic = walletProvider.generateMnemonic();
      newMnemonics = mnemonic;

      newPrivateKey = await walletProvider.getPrivateKey(
          newMnemonics);
      EthereumAddress ethereumAddress = await walletProvider.getPublicKey(
          newPrivateKey);
      newWalletAddress = ethereumAddress.hex;
    }

    try {
      dynamic response = await ApiService.authenticate(
          newWalletAddress,
          newMnemonics,
          newPrivateKey,
        referralController.text
            .trim()
            .isEmpty ? "default" : referralController.text.trim(),
        accountNameController.text.trim(),
        widget.pin,
        widget.isImport
      );

      String responseWalletAddress = json.decode(response)['walletAddress'];

      if (responseWalletAddress == newWalletAddress) {
        String responseBtcWalletAddress = json.decode(
            response)['btcWalletAddress'];
        String responseXrpWalletAddress = json.decode(
            response)['xrpWalletAddress'];
        String responseTonWalletAddress = json.decode(
            response)['tonWalletAddress'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('privateKey', newPrivateKey);
        await prefs.setString('walletAddress', newWalletAddress);
        await prefs.setString('accountName', accountNameController.text.trim());
        await prefs.setString('pinCode', widget.pin);
        await prefs.setString('mnemonics', newMnemonics);
        await prefs.setString('btcWalletAddress', responseBtcWalletAddress);
        await prefs.setString('xrpWalletAddress', responseXrpWalletAddress);
        await prefs.setString('tonWalletAddress', responseTonWalletAddress);

        setState(() {
          _isLoading = false;
          _showSuccess = true;
        });

        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => const BottomBar());
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        "Error",
        "Create account failed.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black),
                SizedBox(height: 20),
                Text(
                  '${widget.isImport ? "Importing wallet..." : "Creating wallet..."}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
              : _showSuccess
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Image.asset(
                    'assets/images/confetti.gif',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.isImport ? "Import wallet successful..." : "Creat wallet successful..."}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 20),

              /// Display Name Input
              TextField(
                controller: accountNameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "Display Name *",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Refcode Input
              TextField(
                controller: referralController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "Refcode (optional)",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                child: ElevatedButton(
                  onPressed: () => {_onConfirm()},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFFF), // Aqua color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    '${widget.isImport ? "Import Wallet" : "Create Wallet"}',
                    style: TextStyle(
                      color: Colors.black, // Dark text for contrast
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (_errorText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      _errorText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
