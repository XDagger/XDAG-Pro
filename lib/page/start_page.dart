import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/home_page.dart';
import 'package:xdag/page/wallet/main_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet? wallet = walletModal.defaultWallet;
    return wallet == null ? const HomePage() : const WalletHomePage();
  }
}
