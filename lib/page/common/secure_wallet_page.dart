import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/create_wallet_widget.dart';

class SecureWalletPage extends StatelessWidget {
  const SecureWalletPage({super.key});
  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    double screenWidth = ScreenHelper.screenWidth;
    var bottomPadding = ScreenHelper.bottomPadding;
    const titleStyle = TextStyle(
      decoration: TextDecoration.none,
      fontSize: 24,
      fontFamily: 'RobotoMono',
      fontWeight: FontWeight.w700,
      color: DarkColors.mainColor,
    );
    const descStyle = TextStyle(
      decoration: TextDecoration.none,
      fontSize: 14,
      fontFamily: 'RobotoMono',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
    return Scaffold(
        appBar: null,
        body: Container(
            color: DarkColors.bgColor,
            child: Column(
              children: [
                CreateWalletStep(onPressed: () {}, step: 2),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                    child: Column(
                      children: [
                        const Text("Create Wallet", style: titleStyle),
                        const SizedBox(height: 30),
                        Expanded(
                            child: Center(
                          child: Image.asset(
                            'images/lock.png',
                            fit: BoxFit.contain,
                          ),
                        )),
                        const SizedBox(height: 20),
                        const Text("Please store the mnemonics in a safe place, preferably on a device without internet access or on paper.", style: descStyle),
                        const SizedBox(height: 12),
                        const Text("When you wish to use the wallet on a new device, this is the only way that the mnemonics can be recovered from your wallet.", style: descStyle),
                      ],
                    ),
                  ),
                ),
                Container(color: DarkColors.lineColor, height: 1, width: double.infinity),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 20, 15, bottomPadding > 0 ? bottomPadding : 20),
                  child: Column(
                    children: [
                      Button(text: "Start", width: screenWidth - 30, bgColor: DarkColors.mainColor),
                      const SizedBox(
                        height: 20,
                      ),
                      Button(text: "Remind Me Later", width: screenWidth - 30, bgColor: DarkColors.lineColor),
                    ],
                  ),
                )
              ],
            )));
  }
}
