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
    TextStyle titleStyle = Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400));
    // TextStyle addressStyle = Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w700));

    return ModalFrame(
      title: AppLocalizations.of(context).qr_code,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ContentBox(
              marginH: marginH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                              child: QrImage(
                                data: wallet.address,
                                version: QrVersions.auto,
                                embeddedImage: const AssetImage('images/logo_b_40.png'),
                                embeddedImageStyle: QrEmbeddedImageStyle(
                                  size: const Size(40, 40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: DarkColors.bgColor),
                  // SizedBox(
                  //   height: 50,
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //           child: Button(
                  //         icon: Icons.download,
                  //         onPressed: () {
                  //           Clipboard.setData(ClipboardData(text: wallet.address));
                  //           Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                  //         },
                  //         title: AppLocalizations.of(context).save_to_album,
                  //       )),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    TextStyle btnStyle = Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400));
    return MyCupertinoButton(padding: EdgeInsets.zero, onPressed: onPressed, child: Text(title, style: btnStyle));
  }
}
