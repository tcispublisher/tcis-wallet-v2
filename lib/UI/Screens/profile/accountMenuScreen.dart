import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:crypto_wallet/providers/wallet_provider.dart';
import 'package:crypto_wallet/UI/Screens/profile/editProfile.dart';

import '../../../controllers/appController.dart';
import '../../../localization/language_constants.dart';
import '../../../services/apiService.dart';
import '../onBoardingScreens/onboardingScreen1.dart';
import '../referralsScreen/referralScreen.dart';

class AccountMenuScreen extends StatefulWidget {
  final String walletAddress;
  final String displayName;
  final double rewards;

  const AccountMenuScreen({
    super.key,
    required this.walletAddress,
    required this.displayName,
    required this.rewards
  });

  @override
  State<AccountMenuScreen> createState() => _AccountMenuScreenState();
}

class _AccountMenuScreenState extends State<AccountMenuScreen> {
  AppController appController=Get.find<AppController>();
  bool isLoading = true;
  bool isSnackbarVisible = false;

  Future<void> _handleGainRewardComing() async {
    dynamic result = await ApiService.claimReward(widget.walletAddress);

    if (!Get.isSnackbarOpen && !isSnackbarVisible) {
      isSnackbarVisible = true;

      Color textColor;
      String title;
      String message = result?.toString() ?? 'Unknown error';

      if (message.contains("successful.")) {
        textColor = Colors.tealAccent;
        title = "Successful";
      } else if (message.contains("There is no reward amount to gain")) {
        textColor = Colors.yellow;
        title = "Warning";
      } else {
        textColor = Colors.redAccent;
        title = "Error";
      }

      Get.snackbar(
        title,
        message,
        backgroundColor: Colors.grey.shade100,
        colorText: textColor,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 1), () {
        isSnackbarVisible = false;
        isLoading = false;
      });
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
        ..minimumFractionDigits = 0
        ..maximumFractionDigits = 2;

      return formatter.format(value);
    } catch (e) {
      return "Invalid balance";
    }
  }

  String _formatWalletAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Future<void> _logout() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.clearPrivateKey();
    Get.offAll(const FullScreenVideoSplash());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(  // Thay SingleChildScrollView bằng ListView
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${widget.displayName}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rewards: ${formatTotalBalance(widget.rewards)} TCIS',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfile()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'Backup',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.black12),

          InkWell(
            onTap: () async => Get.to(SocialScreen()),
            child: _buildMenuItem('Social Member', '>'),
          ),

          InkWell(
            onTap: _handleGainRewardComing,
            child: _buildMenuItem('Claim Rewards', '>'),
          ),

          InkWell(
            onTap: () => Get.to(ReferralScreen()),
            child: _buildMenuItem('Network', '>'),
          ),

          const Divider(color: Colors.black12),
          _buildMenuItem('Language', 'English >'),
          _buildMenuItem('Currency', 'USD >'),
          _buildMenuItem('Theme', 'Light >'),
          _buildMenuItem('Help center', '>'),
          _buildMenuItem('User feedback', '>'),
          InkWell(
            onTap: _logout,
            child: _buildMenuItem('Sign out', '>'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  var isNotifications = true.obs;
  AppController appController = Get.find<AppController>();
  bool isSnackbarVisible = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFF131718),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: const Icon(Icons.arrow_back_ios,
                            color: Colors.black, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${getTranslated(context, "Social Member") ?? "Social Member"}",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: "dmsans",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: isNotifications.value,
                        onChanged: (val) {
                          isNotifications.value = val;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: Get.width,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 1, color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              InkWell(
                                onTap: () {
                                  if (!Get.isSnackbarOpen &&
                                      !isSnackbarVisible) {
                                    isSnackbarVisible = true;
                                    Get.snackbar(
                                      "This feature will be available soon.",
                                      "TCIS Team",
                                      backgroundColor: Colors.greenAccent,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.only(
                                          top: 20, left: 16, right: 16),
                                      duration:
                                      const Duration(seconds: 2),
                                    );
                                    Future.delayed(
                                        const Duration(seconds: 1), () {
                                      isSnackbarVisible = false;
                                    });
                                  }
                                },
                                splashColor: Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${getTranslated(context, "Join us via Telegram") ?? "Join us via Telegram"}",
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.arrow_forward_ios,
                                        color: Colors.black, size: 18)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              InkWell(
                                onTap: () {
                                  if (!Get.isSnackbarOpen &&
                                      !isSnackbarVisible) {
                                    isSnackbarVisible = true;
                                    Get.snackbar(
                                      "This feature will be available soon.",
                                      "TCIS Team",
                                      backgroundColor: Colors.greenAccent,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.only(
                                          top: 20, left: 16, right: 16),
                                      duration:
                                      const Duration(seconds: 2),
                                    );
                                    Future.delayed(
                                        const Duration(seconds: 1), () {
                                      isSnackbarVisible = false;
                                    });
                                  }
                                },
                                splashColor: Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${getTranslated(context, "Join us via X") ?? "Join us via X"}",
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.arrow_forward_ios,
                                        color: Colors.black, size: 18)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
