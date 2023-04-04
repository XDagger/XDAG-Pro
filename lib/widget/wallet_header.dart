import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/page/detail/contacts_page.dart';
import 'package:xdag/page/detail/receive_page.dart';
import 'package:xdag/page/detail/wallet_detail.dart';
import 'package:xdag/widget/home_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletHeader extends StatelessWidget {
  final String address;
  final String balance;
  const WalletHeader({super.key, required this.address, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: DarkColors.blockColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Image.asset('images/logo.png', width: 40, height: 40),
                      const Spacer(),
                      Text("$balance XDAG",
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                  child: SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 3, 10, 5),
                            // alignment: Alignment.center,
                            // height: 20,
                            decoration: BoxDecoration(
                              color: DarkColors.redColorMask2,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "TEST",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Row(
                              children: [
                                Text(address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'RobotoMono',
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white54,
                                    )),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 12,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: address));
                              Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                            },
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: HomeHeaderButton(
                title: AppLocalizations.of(context).security,
                icon: 'images/security.png',
                onPressed: () async {
                  Helper.changeAndroidStatusBar(true);
                  await Helper.showBottomSheet(context, const WalletDetailPage());
                  Helper.changeAndroidStatusBar(false);
                },
              )),
              const SizedBox(width: 15),
              Expanded(
                  child: HomeHeaderButton(
                title: AppLocalizations.of(context).send,
                icon: 'images/send.png',
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: DarkColors.bgColor,
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext buildContext) => const ContactsPage(),
                  );
                },
              )),
              const SizedBox(width: 15),
              Expanded(
                  child: HomeHeaderButton(
                title: AppLocalizations.of(context).receive,
                icon: 'images/receive.png',
                onPressed: () async {
                  Helper.changeAndroidStatusBar(true);
                  await Helper.showBottomSheet(context, const ReceivePage());
                  Helper.changeAndroidStatusBar(false);
                },
              )),
            ],
          ),
        ],
      ),
    );
  }
}
