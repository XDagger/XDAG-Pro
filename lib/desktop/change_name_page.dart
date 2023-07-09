import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeNamePage extends StatefulWidget {
  final int index;
  const ChangeNamePage({super.key, required this.index});

  @override
  State<ChangeNamePage> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeNamePage> {
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
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    Wallet wallet = walletModal.getWalletByIndex(widget.index);
    bool isButtonEnable = walletName.isNotEmpty && walletName != wallet.name;
    return DesktopModalFrame(
        boxSize: const Size(500, 250),
        title: AppLocalizations.of(context).change_wallet_name,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(AppLocalizations.of(context).walletName, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
              const SizedBox(height: 15),
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
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  BottomBtn(
                    bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.mainColor.withOpacity(0.5),
                    disable: !isButtonEnable,
                    text: AppLocalizations.of(context).continueText,
                    onPressed: () {
                      walletModal.changeNameByIndex(walletName, widget.index);
                      Navigator.pop(context);
                    },
                  )
                ],
              )
            ],
          ),
        ));
  }
}
