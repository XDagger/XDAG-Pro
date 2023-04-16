import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/modal_frame.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    ScreenHelper.initScreen(context);
    double marginH = 20;
    double paddingH = 15;
    TextStyle titleStyle = const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "RobotoMono", fontWeight: FontWeight.w400);
    TextStyle addressStyle = const TextStyle(color: Colors.white54, fontSize: 16, fontFamily: "RobotoMono", fontWeight: FontWeight.w700);

    return ModalFrame(
        title: '${AppLocalizations.of(context).receive} XDAG',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ContentBox(
              marginH: marginH,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).show_QR, style: titleStyle),
                    const SizedBox(height: 15),
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: QrImage(data: wallet.address, version: QrVersions.auto),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ContentBox(
              marginH: marginH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Container(height: 1, color: DarkColors.bgColor),
                  SizedBox(
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
            //Column(children: [const SizedBox(height: 20), Image.asset("images/logo.png", width: 50, height: 50)])
          ],
        ));
  }
}

class ContentBox extends StatelessWidget {
  final double marginH;
  final Widget child;
  const ContentBox({super.key, required this.marginH, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    return MyCupertinoButton(
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
