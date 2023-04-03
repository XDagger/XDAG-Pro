import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/page/wallet/wallet_page.dart';
import 'package:xdag/page/wallet/wallet_setting.dart';
import 'package:xdag/widget/nav_button.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  List<Widget> _bottomNavPages = [];
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _bottomNavPages = [
      const WalletPage(),
      const WalletSettingPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    return Scaffold(
        key: Helper.scaffoldMessengerKey,
        appBar: null,
        body: IndexedStack(index: _currentIndex, children: _bottomNavPages),
        backgroundColor: DarkColors.bgColor,
        bottomNavigationBar: BottomAppBar(
          color: DarkColors.bgColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(child: BottomNavButton(index: _currentIndex, type: 0, onPressed: () => setState(() => _currentIndex = 0))),
              Expanded(child: BottomNavButton(index: _currentIndex, type: 1, onPressed: () => setState(() => _currentIndex = 1))),
            ],
          ),
        ));
  }
}
