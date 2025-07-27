import 'package:crypto_wallet/UI/Screens/profile/secretRecoveryPhrase.dart';
import 'package:crypto_wallet/UI/Screens/profile/showPrivateKey.dart';
import 'package:crypto_wallet/UI/Screens/profile/secretRecoveryPhraseTon.dart';
import 'package:crypto_wallet/UI/Screens/profile/showPrivateKeyRipple.dart';
import 'package:crypto_wallet/UI/Screens/profile/showPrivateKeyBitcoin.dart';
import 'package:crypto_wallet/constants/colors.dart';
import 'package:crypto_wallet/controllers/appController.dart';
import 'package:crypto_wallet/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            getTranslated(context, "Backup Options") ?? "Backup Options",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: "dmsans",
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildOptionCard(
                title: getTranslated(context, "Show Mnemonics Phrase BSC") ?? "Show Mnemonics Phrase BSC",
                onTap: () => Get.to(SecretRecoveryPharase()),
              ),
              _buildOptionCard(
                title: getTranslated(context, "Show Private Key BSC") ?? "Show Private Key BSC",
                onTap: () => Get.to(ShowPrivateKey()),
              ),
              _buildOptionCard(
                title: getTranslated(context, "Show Private Key Bitcoin") ?? "Show Private Key Bitcoin",
                onTap: () => Get.to(ShowPrivateKeyBitcoin()),
              ),
              _buildOptionCard(
                title: getTranslated(context, "Show Private Key Ripple") ?? "Show Private Key Ripple",
                onTap: () => Get.to(ShowPrivateKeyRipple()),
              ),
              _buildOptionCard(
                title: getTranslated(context, "Show Mnemonics TON Network") ?? "Show Mnemonics TON Network",
                onTap: () => Get.to(SecretRecoveryPharaseTon()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: "dmsans",
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: headingColor.value,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}