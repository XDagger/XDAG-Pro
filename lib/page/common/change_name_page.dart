import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/input.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeNamePage extends StatefulWidget {
  const ChangeNamePage({super.key});

  @override
  State<ChangeNamePage> createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  final _focusNode = FocusNode();
  late TextEditingController controller;
  String walletName = "";
  bool isLoad = false;
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    bool isButtonEnable = walletName.isNotEmpty && walletName != wallet.name;
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: GestureDetector(
        child: Column(
          children: [
            NavHeader(title: AppLocalizations.of(context).change_wallet_name),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).walletName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 10),
                    Input(
                      defaultValue: wallet.name,
                      isFocus: true,
                      focusNode: _focusNode,
                      hintText: AppLocalizations.of(context).walletName,
                      onChanged: (p0) {
                        setState(() {
                          walletName = p0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(color: DarkColors.lineColor, height: 1, width: double.infinity),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Button(
                    text: AppLocalizations.of(context).continueText,
                    width: ScreenHelper.screenWidth - 30,
                    bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                    textColor: Colors.white,
                    disable: !isButtonEnable,
                    isLoad: isLoad,
                    onPressed: () async {
                      setState(() {
                        isLoad = true;
                      });
                      await walletModal.changeName(walletName);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
