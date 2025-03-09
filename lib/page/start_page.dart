import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/page/home_page.dart';
import 'package:xdag/page/wallet/main_page.dart';
import 'package:back_to_home/back_to_home.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int needCheck = -1;
  DateTime? lastPopTime; // 0: no check, 1: to check, 2: check ok
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
      Wallet? wallet = walletModal.defaultWallet;
      var flag = wallet == null;
      setState(() {
        needCheck = flag ? 0 : 1;
      });
      if (!flag) {
        showModalBottomSheet(
          backgroundColor: DarkColors.bgColor,
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          builder: (BuildContext buildContext) => CheckPage(
              canClose: false,
              checkCallback: (bool isCheck) async {
                if (isCheck) {
                  setState(() {
                    needCheck = 2;
                  });
                }
              }),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet? wallet = walletModal.defaultWallet;
    if (needCheck == -1 || needCheck == 1) {
      return const Scaffold(
        backgroundColor: DarkColors.bgColor,
        body: null,
      );
    }
    return PopScope(
      canPop: !Platform.isAndroid, // 如果是 Android，则拦截返回键
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && Platform.isAndroid) {
          BackToHome.backToPhoneHome();
        }
      },
      child: wallet == null ? const HomePage() : const WalletHomePage(),
    );
  }
}
