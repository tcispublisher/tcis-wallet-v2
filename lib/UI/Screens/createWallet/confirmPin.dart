import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/bottomNavBar.dart';
import 'createAccount.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String pin;
  final bool isImport;
  final String walletAddress;
  final String publicKey;
  final String privateKey;
  final String mnemonics;

  const ConfirmPinScreen({
    super.key,
    required this.pin,
    required this.isImport,
    required this.walletAddress,
    required this.publicKey,
    required this.privateKey,
    required this.mnemonics
  });

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  String _pin = '';
  int _currentInputIndex = 0;
  bool _isLoading = false;
  bool _showSuccess = false;
  String _errorText = '';

  void _addDigit(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _currentInputIndex = _pin.length;
        _errorText = '';
      });
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _currentInputIndex = _pin.length;
      });
    }
  }

  Future<void> _onConfirm() async {
    if (_pin.length < 6) return;

    if (_pin != widget.pin) {
      setState(() {
        _errorText = 'PIN does not match';
        _pin = '';
        _currentInputIndex = 0;
      });
      return;
    }

    Get.to(() => CreateAccountScreen(pin: _pin,
        isImport: widget.isImport,
        walletAddress: widget.walletAddress,
        publicKey: widget.publicKey,
        privateKey: widget.privateKey,
        mnemonics: widget.mnemonics,
    ));
  }

  Widget _buildPinBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool hasDigit = index < _pin.length;
        bool isCurrent = index == _currentInputIndex && _pin.length < 6;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCurrent ? Colors.blue : Colors.grey,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              hasDigit ? _pin[index] : '',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboardButton(String label, {VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKeyboardButton('1', onPressed: () => _addDigit('1')),
              _buildKeyboardButton('2', onPressed: () => _addDigit('2')),
              _buildKeyboardButton('3', onPressed: () => _addDigit('3')),
            ],
          ),
          Row(
            children: [
              _buildKeyboardButton('4', onPressed: () => _addDigit('4')),
              _buildKeyboardButton('5', onPressed: () => _addDigit('5')),
              _buildKeyboardButton('6', onPressed: () => _addDigit('6')),
            ],
          ),
          Row(
            children: [
              _buildKeyboardButton('7', onPressed: () => _addDigit('7')),
              _buildKeyboardButton('8', onPressed: () => _addDigit('8')),
              _buildKeyboardButton('9', onPressed: () => _addDigit('9')),
            ],
          ),
          Row(
            children: [
              _buildKeyboardButton('⌫', onPressed: _removeDigit),
              _buildKeyboardButton('0', onPressed: () => _addDigit('0')),
              _buildKeyboardButton('OK', onPressed: _onConfirm),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black),
                SizedBox(height: 20),
                Text(
                  'Creating wallet...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
              : _showSuccess
              ?
          Center(
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
                const Text(
                  'Create wallet successful',
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
              // Rest of your normal UI
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirm your PIN code",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    textAlign: TextAlign.left,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Re-enter the 6-digit PIN to confirm.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(child: _buildPinBoxes()),
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
              _buildNumberPad(),
            ],
          ),
        ),
      ),
    );
  }
}
