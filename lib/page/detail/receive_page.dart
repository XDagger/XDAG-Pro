import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/modal_frame.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    double screenWidth = ScreenHelper.screenWidth;
    double screenHeight = ScreenHelper.screenHeight;
    double topPadding = ScreenHelper.topPadding;
    double marginH = 20;
    double paddingH = 15;
    double width = screenHeight < 700 ? 280 : screenWidth - marginH * 2;
    double w = width - paddingH * 2;
    TextStyle titleStyle = const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "RobotoMono", fontWeight: FontWeight.w400);
    TextStyle addressStyle = const TextStyle(color: Colors.white54, fontSize: 16, fontFamily: "RobotoMono", fontWeight: FontWeight.w700);

    Widget icon = (screenHeight - topPadding - 40) - (330 + width) < 0 ? const SizedBox() : Column(children: [const SizedBox(height: 20), Image.asset("images/logo.png", width: 50, height: 50)]);
    return ModalFrame(
        title: '${AppLocalizations.of(context).receive} XDAG',
        // height: 327 + width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ContentBox(
              width: width,
              marginH: marginH,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).show_QR, style: titleStyle),
                    const SizedBox(height: 15),
                    Container(
                      width: w,
                      height: w,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: QrImage(data: wallet.address, version: QrVersions.auto),
                    ),
                  ],
                ),
              ),
            ),
            ContentBox(
              width: width,
              marginH: marginH,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(paddingH, 15, paddingH, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).share_wallet_address, style: titleStyle),
                        const SizedBox(height: 8),
                        Text(wallet.address, style: addressStyle),
                      ],
                    ),
                  ),
                  Container(width: width, height: 1, color: DarkColors.bgColor),
                  SizedBox(
                    width: width,
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                            child: Button(
                          icon: Icons.copy_rounded,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: wallet.address));
                            Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                          },
                          title: AppLocalizations.of(context).copy,
                        )),
                        // Container(width: 1, color: DarkColors.bgColor),
                        // Expanded(
                        //     child: Button(
                        //   icon: Icons.share_rounded,
                        //   onPressed: () {},
                        //   title: AppLocalizations.of(context).share,
                        // )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            icon
          ],
        ));
  }
}

class ContentBox extends StatelessWidget {
  final double width;
  final double marginH;
  final Widget child;
  const ContentBox({super.key, required this.width, required this.marginH, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.fromLTRB(marginH, 20, marginH, 0),
      decoration: BoxDecoration(
        color: DarkColors.blockColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class Button extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  const Button({super.key, required this.title, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    TextStyle btnStyle = const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "RobotoMono", fontWeight: FontWeight.w400);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10), Text(title, style: btnStyle)],
      ),
    );
  }
}
