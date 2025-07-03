

import 'package:crypto_wallet/Constants/colors.dart';
import 'package:crypto_wallet/UI/Screens/TransactionHistoryScreen/TransactionScreen.dart';
import 'package:crypto_wallet/UI/Screens/TransactionHistoryScreen/rewardHistory.dart';
import 'package:crypto_wallet/UI/Screens/homeScreen/homeScreen.dart';
import 'package:crypto_wallet/UI/Screens/market/market.dart';
import 'package:crypto_wallet/UI/Screens/nfts/nftsScreen.dart';
import 'package:crypto_wallet/UI/Screens/profile/profile.dart';
import 'package:crypto_wallet/UI/Screens/stakingScreen/stakingScreen.dart';
import 'package:crypto_wallet/UI/Screens/swapScreens/swapScreen.dart';
import 'package:crypto_wallet/controllers/appController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';



class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  List pages = [
    HomeScreen(),
    StakingScreen(),
    MarketScreen(),
    RewardHistoryScreen(),
    ProfileScreen(),
  ];

  AppController appController = Get.find<AppController>();
  DateTime? lastPressed;
  late DateTime currentBackPressTime;

  List<bool> isLoadingPages = [false, false, false, false, false]; // Mỗi trang có một trạng thái loading riêng

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    appController.selectedBOttomTabIndex.value = 0;
  }

  // Hàm kiểm tra trạng thái loading của trang trước khi chuyển tab
  bool canSwitchTab(int index) {
    return !isLoadingPages[index];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();

          if (lastPressed == null || now.difference(lastPressed!) > Duration(seconds: 1)) {
            lastPressed = now;
            return false;
          }

          return true;
        },
        child: Scaffold(
            // backgroundColor: Colors.black,
            bottomNavigationBar: Obx(
              ()=> Container(
                 height: 60,
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                decoration: BoxDecoration(
                     color: Color(0xFFFFFFFF)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              appController.selectedBOttomTabIndex.value = 0;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: 0.6,
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      tween: ColorTween(
                                        begin: appController.selectedBOttomTabIndex.value == 0
                                            ? Color(0xFF8F9696)
                                            : Color(0xFF00FFFF),
                                        end: appController.selectedBOttomTabIndex.value == 0
                                            ? Color(0xFF00FFFF)
                                            : Color(0xFF8F9696),
                                      ),

                                      builder: (context, color, child) {
                                        return SvgPicture.asset(
                                          "assets/svgs/home.svg",
                                          color: color,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              appController.selectedBOttomTabIndex.value = 1;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: 0.6,
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: Duration(milliseconds: 300),
                                      tween: ColorTween(
                                        begin: appController.selectedBOttomTabIndex.value == 1
                                            ? Color(0xFF8F9696)
                                            : Color(0xFF00FFFF),
                                        end: appController.selectedBOttomTabIndex.value == 1
                                            ? Color(0xFF00FFFF)
                                            : Color(0xFF8F9696),
                                      ),

                                      builder: (context, color, _) => SvgPicture.asset(
                                        appController.selectedBOttomTabIndex.value == 1
                                            ? "assets/svgs/market.svg"
                                            : "assets/svgs/market.svg",
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              appController.selectedBOttomTabIndex.value = 2;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: 0.6,
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: Duration(milliseconds: 300),
                                      tween: ColorTween(
                                        begin: appController.selectedBOttomTabIndex.value == 2
                                            ? Color(0xFF8F9696)
                                            : Color(0xFF00FFFF),
                                        end: appController.selectedBOttomTabIndex.value == 2
                                            ? Color(0xFF00FFFF)
                                            : Color(0xFF8F9696),
                                      ),

                                      builder: (context, color, _) => SvgPicture.asset(
                                        appController.selectedBOttomTabIndex.value == 2
                                            ? "assets/svgs/trade.svg"
                                            : "assets/svgs/trade.svg",
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              appController.selectedBOttomTabIndex.value = 3;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: 0.6,
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: Duration(milliseconds: 300),
                                      tween: ColorTween(
                                        begin: appController.selectedBOttomTabIndex.value == 3
                                            ? Color(0xFF8F9696)
                                            : Color(0xFF00FFFF),
                                        end: appController.selectedBOttomTabIndex.value == 3
                                            ? Color(0xFF00FFFF)
                                            : Color(0xFF8F9696),
                                      ),
                                      builder: (context, color, _) => SvgPicture.asset(
                                        appController.selectedBOttomTabIndex.value == 3
                                            ? "assets/svgs/discover.svg"
                                            : "assets/svgs/discover.svg",
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              appController.selectedBOttomTabIndex.value = 4;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: 0.6,
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: Duration(milliseconds: 300),
                                      tween: ColorTween(
                                        begin: appController.selectedBOttomTabIndex.value == 4
                                            ? Color(0xFF8F9696)
                                            : Color(0xFF00FFFF),
                                        end: appController.selectedBOttomTabIndex.value == 4
                                            ? Color(0xFF00FFFF)
                                            : Color(0xFF8F9696),
                                      ),

                                      builder: (context, color, _) => SvgPicture.asset(
                                        appController.selectedBOttomTabIndex.value == 4
                                            ? "assets/svgs/user.svg"
                                            : "assets/svgs/user.svg",
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: pages.elementAt(appController.selectedBOttomTabIndex.value),
          ),
      ),
    );
  }
}
