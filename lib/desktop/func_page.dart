import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/back_up_page.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key});
  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    Wallet wallet = walletModal.getWallet();
    return DesktopModalFrame(
        boxSize: const Size(400, 420),
        title: AppLocalizations.of(context)!.qr_code,
        child: Expanded(
          child: Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: QrImage(
                  data: wallet.address,
                  version: QrVersions.auto,
                  embeddedImage: const AssetImage('images/logo_b_40.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(size: const Size(40, 40)),
                ),
              ),
            ),
          ),
        ));
  }
}

class BackupPage extends StatelessWidget {
  final String data;
  const BackupPage({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    var mnemonicList = data.trim().split(' ');
    List<MnemonicItem> mnemonicItemList = [];
    if (mnemonicList.length > 2) {
      mnemonicList.asMap().forEach((index, value) {
        mnemonicItemList.add(MnemonicItem(index + 1, value));
      });
    }

    return DesktopModalFrame(
        boxSize: const Size(700, 400),
        title: AppLocalizations.of(context)!.backup,
        child: Expanded(
          child: Center(
              child: mnemonicItemList.isEmpty
                  ? Text(data, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)))
                  : Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: mnemonicItemList
                          .map((e) => Container(
                              // width: (ScreenHelper.screenWidth - 30 - 2 - 60) * 0.5,
                              width: 190,
                              height: 50,
                              decoration: BoxDecoration(
                                color: DarkColors.blockColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text('${e.index}. ${e.value}', style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                              )))
                          .toList(),
                    )),
        ));
  }
}
