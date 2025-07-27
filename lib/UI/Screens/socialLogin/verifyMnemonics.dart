import 'dart:convert';

import 'package:crypto_wallet/UI/Screens/createWallet/createPin.dart';
import 'package:crypto_wallet/services/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../localization/language_constants.dart';
import '../../common_widgets/bottomNavBar.dart';

class VerifyMnemonicsScreen extends StatefulWidget {
  const VerifyMnemonicsScreen({super.key});

  @override
  State<VerifyMnemonicsScreen> createState() => _VerifyMnemonicsScreenState();
}

class _VerifyMnemonicsScreenState extends State<VerifyMnemonicsScreen> {
  final List<TextEditingController> _controllers = List.generate(
    12,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    12,
        (index) => FocusNode(),
  );
  final List<bool> _wordValidity = List.generate(12, (index) => true);
  bool _isLoading = false;

  bool _isValidWord(String word) {
    if (word.isEmpty) return true;
    return word.length > 2 &&
        !word.contains(RegExp(r'[0-9]')) &&
        !word.contains(' ');
  }

  // New validation: Check if word is same as previous one
  bool _isNotSameAsPrevious(int index) {
    if (index == 0) return true; // First word has no previous to compare
    final currentWord = _controllers[index].text.trim();
    final previousWord = _controllers[index - 1].text.trim();
    return currentWord.isEmpty || currentWord != previousWord;
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus) {
          _validateWord(i);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _validateWord(int index) {
    final word = _controllers[index].text.trim();
    final isValid = (word.isEmpty || _isValidWord(word)) &&
        _isNotSameAsPrevious(index);

    setState(() {
      _wordValidity[index] = isValid;
    });
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {
      for (var i = 0; i < _wordValidity.length; i++) {
        _wordValidity[i] = true;
      }
    });
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final text = clipboardData?.text?.trim() ?? '';

      if (text.isEmpty) {
        Get.snackbar(
          getTranslated(context, 'Error') ?? 'Error',
          getTranslated(context, 'Clipboard is empty') ?? 'Clipboard is empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final words = text.split(' ');
      if (words.length != 12) {
        Get.snackbar(
          getTranslated(context, 'Error') ?? 'Error',
          getTranslated(context, 'Invalid format: Must contain exactly 12 words') ?? 'Invalid format: Must contain exactly 12 words',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate all words
      for (var word in words) {
        if (!_isValidWord(word)) {
          Get.snackbar(
            getTranslated(context, 'Error') ?? 'Error',
            getTranslated(context, 'Invalid word found in clipboard') ?? 'Invalid word found in clipboard',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Check for consecutive duplicates
      for (var i = 1; i < words.length; i++) {
        if (words[i] == words[i-1]) {
          Get.snackbar(
            getTranslated(context, 'Error') ?? 'Error',
            getTranslated(context, 'Consecutive duplicate words found') ?? 'Consecutive duplicate words found',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      // All checks passed - paste the words
      for (var i = 0; i < _controllers.length; i++) {
        _controllers[i].text = words[i];
        _wordValidity[i] = true;
      }

    } catch (e) {
      Get.snackbar(
        getTranslated(context, 'Error') ?? 'Error',
        getTranslated(context, 'Failed to paste from clipboard') ?? 'Failed to paste from clipboard',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _validateMnemonics() async {
    // First validate all words
    for (var i = 0; i < _controllers.length; i++) {
      final word = _controllers[i].text.trim();
      if (word.isEmpty || !_isValidWord(word)) {
        setState(() {
          _wordValidity[i] = false;
        });
        Get.snackbar(
          getTranslated(context, 'Error') ?? 'Error',
          getTranslated(context, 'Please enter valid words in all fields') ?? 'Please enter valid words in all fields',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    final mnemonics = _controllers.map((c) => c.text.trim()).toList();
    final mnemonicsConverted = mnemonics.join(" ");

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.verifyMnemonics(mnemonicsConverted);

      if (response != null && response['walletAddress'] != null) {
        final privateKey = response['privateKey'] as String;
        final publicKey = response['publicKey'] as String;
        final walletAddress = response['walletAddress'] as String;

        if (response['isExisted'] == "Not existed") {
          Get.offAll(
            CreatePinScreen(
              isImport: true,
              walletAddress: walletAddress,
              publicKey: publicKey,
              privateKey: privateKey,
              mnemonics: mnemonicsConverted,
            ),
            transition: Transition.rightToLeft,
          );
        } else {
          String responseBtcWalletAddress = response['btcWalletAddress'] as String;
          String responseXrpWalletAddress = response['xrpWalletAddress'] as String;
          String responseTonWalletAddress = response['tonWalletAddress'] as String;
          String responseAccountName = response['accountName'] as String;
          String responsePinCode = response['pinCode'] as String;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('privateKey', privateKey);
          await prefs.setString('walletAddress', walletAddress);
          await prefs.setString('accountName', responseAccountName);
          await prefs.setString('pinCode', responsePinCode);
          await prefs.setString('mnemonics', mnemonicsConverted);
          await prefs.setString('btcWalletAddress', responseBtcWalletAddress);
          await prefs.setString('xrpWalletAddress', responseXrpWalletAddress);
          await prefs.setString('tonWalletAddress', responseTonWalletAddress);

          Get.snackbar(
            getTranslated(context, 'Success') ?? 'Success',
            getTranslated(context, 'Import Wallet Successful') ?? 'Import Wallet Successful',
            backgroundColor: Colors.tealAccent,
            colorText: Colors.white,
          );

          Future.delayed(const Duration(seconds: 1), () {
            Get.offAll(() => const BottomBar());
          });
        }
      } else {
        Get.snackbar(
          getTranslated(context, 'Error') ?? 'Error',
          getTranslated(context, 'Invalid mnemonics') ?? 'Invalid mnemonics',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        getTranslated(context, 'Error') ?? 'Error',
        getTranslated(context, 'Connection error') ?? 'Connection error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _moveFocusToNext(int index) {
    _validateWord(index);

    if (index < _controllers.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
      _validateMnemonics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              getTranslated(context, "Import with seed phrase") ?? "Import with seed phrase",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: getTranslated(context, "Supports 12-word seedphrase imports. When entering a seed phrase, separate each word with a space") ??
                        "Supports 12-word seedphrase imports. When entering a seed phrase, separate each word with a space",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: '${index + 1}',
                      labelStyle: TextStyle(
                        color: _wordValidity[index] ? Colors.grey : Colors.red,
                      ),
                      focusColor: Colors.indigo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _wordValidity[index] ? Colors.grey : Colors.red,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _wordValidity[index] ? Colors.indigo : Colors.red,
                        ),
                      ),
                      errorText: _wordValidity[index]
                          ? null
                          : _controllers[index].text.trim() == _controllers[index-1].text.trim()
                          ? 'Same as previous'
                          : 'Invalid word',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    textInputAction: index < 11 ? TextInputAction.next : TextInputAction.done,
                    onSubmitted: (_) => _moveFocusToNext(index),
                    onChanged: (value) {
                      if (!_wordValidity[index]) {
                        setState(() {
                          _wordValidity[index] = true;
                          if (index > 0) {
                            _wordValidity[index-1] = true;
                          }
                        });
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _clearAllFields,
                    child: Text(
                      getTranslated(context, "Clear All") ?? "Clear All",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _pasteFromClipboard,
                    child: Text(
                      getTranslated(context, "Paste") ?? "Paste",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20AEA9),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _validateMnemonics,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  getTranslated(context, "Import") ?? "Import",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}