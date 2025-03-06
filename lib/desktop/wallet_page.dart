import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/contacts_page.dart';
import 'package:xdag/desktop/keep_alive_wapper.dart';
import 'package:xdag/desktop/main_page.dart';
import 'package:xdag/desktop/setting_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/page/detail/wallet_list_page.dart';
import 'package:xdag/widget/desktop.dart';

enum DrawerType {
  // 0 wallet list
  // 1 wallet setting
  // 2 contact detail
  // 3 transaction send
  // 4 transaction detail
  none,
  walletList,
  walletSetting,
  contactDetail,
  transactionSend,
  transactionDetail,
}

class DesktopWalletPage extends StatefulWidget {
  const DesktopWalletPage({super.key});

  @override
  State<DesktopWalletPage> createState() => _DesktopWalletPageState();
}

class _DesktopWalletPageState extends State<DesktopWalletPage> {
  int index = 0;

  DrawerType type = DrawerType.none;
  final pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _openDrawer(DrawerType index) {
    setState(() {
      type = index;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  // void _closeDrawer() {
  //   setState(() {
  //     type = DrawerType.none;
  //   });
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    // WalletModal walletModal = Provider.of<WalletModal>(context);
    // Wallet wallet = walletModal.getWallet();
    Widget drawer = Container();
    if (type == DrawerType.walletList) {
      drawer = const WalletListPage();
    }
    if (type == DrawerType.walletSetting) {
      // drawer = const WalletDetailPage();
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DarkColors.bgColor,
      endDrawer: SizedBox(width: 480, child: Drawer(child: drawer)),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: const BoxDecoration(
              color: DarkColors.blockColor,
              // boxShadow: [BoxShadow(color: DarkColors.lineColor, offset: Offset(1, 0), blurRadius: 1)],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('images/logo40.png', width: 40, height: 40),
                      const SizedBox(height: 8),
                      Text(
                        'XDAG-Pro',
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
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
                          title: AppLocalizations.of(context)!.wallet,
                          icon: 'images/wallet1.png',
                          onTap: () {
                            setState(() => index = 0);
                            pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          },
                          isSelect: index == 0,
                          selectIcon: 'images/wallet_white.png'),
                      const SizedBox(height: 10),
                      NavButton(
                          title: AppLocalizations.of(context)!.contacts,
                          icon: 'images/contacts1.png',
                          onTap: () {
                            setState(() => index = 1);
                            pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          },
                          isSelect: index == 1,
                          selectIcon: 'images/contacts_white.png'),
                      const SizedBox(height: 10),
                      NavButton(
                          title: AppLocalizations.of(context)!.setting,
                          icon: 'images/set1.png',
                          onTap: () {
                            setState(() => index = 2);
                            pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          },
                          isSelect: index == 2,
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
              itemCount: 3,
              // allowImplicitScrolling: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) {
                if (index == 0) return KeepAliveWrapper(child: MainPage(showDrawer: _openDrawer));
                if (index == 1) return const KeepAliveWrapper(child: ContactsPage());
                return const KeepAliveWrapper(child: SettingPage());
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
