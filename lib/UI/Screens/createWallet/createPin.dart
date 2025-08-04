import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/language_constants.dart';
import 'confirmPin.dart';

class CreatePinScreen extends StatefulWidget {
  final bool isImport;
  final String walletAddress;
  final String publicKey;
  final String privateKey;
  final String mnemonics;

  const CreatePinScreen({
    super.key,
    required this.isImport,
    required this.walletAddress,
    required this.publicKey,
    required this.privateKey,
    required this.mnemonics,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = "";
  int _currentInputIndex = 0;

  void _onNext() {
    if (_pin.length == 6) {
      Get.to(() => ConfirmPinScreen(
          pin: _pin,
          isImport: widget.isImport,
          walletAddress: widget.walletAddress,
          publicKey: widget.publicKey,
          privateKey: widget.privateKey,
          mnemonics: widget.mnemonics,
      ));
    }
  }

  void _addDigit(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _currentInputIndex = _pin.length;
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
            color: Colors.grey.shade200,
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
            backgroundColor: Color(0xFFFFFFFF),
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
      padding: const EdgeInsets.only(bottom: 40),
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
              _buildKeyboardButton('OK', onPressed: _onNext),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${getTranslated(context, "Set your 6-digit PIN") ?? "Set your 6-digit PIN"}",
                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold,),
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: getTranslated(context, "Your PIN is used to verify your identity. TCIS Wallet does not store your PIN for you, so please keep it safe. ") ??
                            "Your PIN is used to verify your identity. TCIS Wallet does not store your PIN for you, so please keep it safe. ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: getTranslated(context, "If you lose it, you will not be able to recover it.") ??
                            "If you lose it, you will not be able to recover it.",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildPinBoxes(),
            const Spacer(),
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }
}