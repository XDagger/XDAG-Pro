import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/main_page.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/desktop/setting_page.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/desktop.dart';

class DesktopWalletPage extends StatefulWidget {
  const DesktopWalletPage({super.key});

  @override
  State<DesktopWalletPage> createState() => _DesktopWalletPageState();
}

class _DesktopWalletPageState extends State<DesktopWalletPage> {
  int index = 0;
  final pageController = PageController();
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(Global.windowMaxSize);
    await windowManager.setSize(Global.windowMaxSize);
    await windowManager.center();
  }

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: const BoxDecoration(
              color: DarkColors.blockColor,
              boxShadow: [BoxShadow(color: DarkColors.lineColor, offset: Offset(1, 0), blurRadius: 1)],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('images/logo40.png', width: 40, height: 40),
                      const SizedBox(width: 10),
                      Text(
                        'XDAG-Pro',
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NavButton(
                          title: AppLocalizations.of(context).wallet,
                          icon: 'images/wallet1.png',
                          onTap: () {
                            setState(() => index = 0);
                            pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          },
                          isSelect: index == 0,
                          selectIcon: 'images/wallet_white.png'),
                      const SizedBox(height: 10),
                      NavButton(
                          title: AppLocalizations.of(context).setting,
                          icon: 'images/set1.png',
                          onTap: () {
                            setState(() => index = 1);
                            pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          },
                          isSelect: index == 1,
                          selectIcon: 'images/set_white.png'),
                    ],
                  ),
                ),
                Text('Version ${Global.version}(${Global.buildNumber})', style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w400))),
                const SizedBox(height: 20)
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: 2,
              // 纵向
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) {
                return index == 0 ? const MainPage() : const SettingPage();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final String title;
  final String selectIcon;
  final String icon;
  final VoidCallback onTap;
  final bool isSelect;
  const NavButton({super.key, required this.title, required this.icon, required this.onTap, required this.isSelect, required this.selectIcon});

  @override
  Widget build(BuildContext context) {
    return MyCupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        // border radius 10
        height: 50,
        margin: const EdgeInsets.only(left: 20, right: 20),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: isSelect ? DarkColors.mainColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(isSelect ? selectIcon : icon, width: 25, height: 25),
            const SizedBox(width: 10),
            Center(
              child: Text(
                title,
                style: Helper.fitChineseFont(
                  context,
                  TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelect ? Colors.white : DarkColors.bottomNavColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
