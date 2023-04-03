import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/back_up_page.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/widget/label_button.dart';
import 'package:xdag/widget/modal_frame.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletDetailPage extends StatelessWidget {
  const WalletDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    return ModalFrame(
        title: AppLocalizations.of(context).wallet_details,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("images/logo.png", width: 80, height: 80),
              const SizedBox(height: 5),
              SizedBox(
                height: 36,
                child: Row(
                  children: [
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          Text(wallet.address, style: const TextStyle(fontSize: 12, fontFamily: 'RobotoMono', fontWeight: FontWeight.w400, color: Colors.white)),
                          const SizedBox(width: 5),
                          const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                        ],
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: wallet.address));
                        Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LabelButton(
                type: 0,
                label: AppLocalizations.of(context).walletName,
                onPressed: () async {
                  Helper.changeAndroidStatusBar(false);
                  await Navigator.pushNamed(context, "/change_name");
                  Helper.changeAndroidStatusBar(true);
                },
                child: Row(
                  children: [
                    Text(wallet.name, style: const TextStyle(fontSize: 12, fontFamily: 'RobotoMono', fontWeight: FontWeight.w500, color: Colors.white54)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              LabelButton(
                  type: 1,
                  onPressed: () async {
                    Helper.changeAndroidStatusBar(false);
                    await showModalBottomSheet(
                      backgroundColor: DarkColors.bgColor,
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext buildContext) => CheckPage(checkCallback: (bool isCheck) async {
                        if (isCheck) {
                          String? data = await Global.getWalletDataByAddress(wallet.address);
                          if (data != null && context.mounted) {
                            Helper.changeAndroidStatusBar(false);
                            if (data.contains(" ")) {
                              await Navigator.pushNamed(context, "/back_up", arguments: BackUpPageRouteParams(data, 0));
                            } else {
                              await Navigator.pushNamed(context, "/back_up", arguments: BackUpPageRouteParams(data, 1));
                            }
                            Helper.changeAndroidStatusBar(true);
                          }
                        }
                      }),
                    );
                    Helper.changeAndroidStatusBar(true);
                  },
                  label: AppLocalizations.of(context).backup),
            ],
          ),
        ));
  }
}
