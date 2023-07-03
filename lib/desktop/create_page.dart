import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/input.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

class DesktopCreateWalletPage extends StatefulWidget {
  final Size boxSize;
  const DesktopCreateWalletPage({super.key, required this.boxSize});

  @override
  State<DesktopCreateWalletPage> createState() => _DesktopCreateWalletPageState();
}

class _DesktopCreateWalletPageState extends State<DesktopCreateWalletPage> {
  bool isAgree = false;
  final _focusNode2 = FocusNode();
  String walletName = '';
  bool isLoad = false;
  Isolate? isolate;

  @override
  void dispose() {
    isolate?.kill(priority: Isolate.immediate);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void isolateFunction(SendPort sendPort) async {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);

      receivePort.listen((data) async {
        var isPrivateKey = data[0];
        var importContent = data[1] as String;
        importContent = importContent.isEmpty ? bip39.generateMnemonic(strength: 128) : importContent;
        bip32.BIP32 wallet = Helper.createWallet(isPrivate: isPrivateKey, content: importContent);
        String address = Helper.getAddressByWallet(wallet);
        sendPort.send(['success', address, importContent]);
      });
    }

    bool isButtonEnable = isAgree && walletName.isNotEmpty;
    WalletModal walletModal = Provider.of<WalletModal>(context);
    return DesktopModalFrame(
      boxSize: widget.boxSize,
      title: AppLocalizations.of(context).createWallet,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).walletName, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
            const SizedBox(height: 15),
            Input(
              focusNode: _focusNode2,
              isFocus: true,
              hintText: AppLocalizations.of(context).walletName,
              onChanged: (p0) => setState(() => walletName = p0),
            ),
            const Spacer(),
            MyRadioButton(
              title: AppLocalizations.of(context).createWalletTips,
              isCheck: isAgree,
              onTap: () {
                setState(() {
                  isAgree = !isAgree;
                });
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Spacer(),
                BottomBtn(
                  bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.mainColor.withOpacity(0.5),
                  disable: !isButtonEnable,
                  isLoad: isLoad,
                  text: AppLocalizations.of(context).continueText,
                  onPressed: () async {
                    if (isLoad) return;
                    setState(() {
                      isLoad = true;
                    });
                    print("walletName: $walletName");
                    final receivePort = ReceivePort();
                    isolate = await Isolate.spawn(isolateFunction, receivePort.sendPort);
                    receivePort.listen((data) async {
                      if (data is SendPort) {
                        var subSendPort = data;
                        subSendPort.send([false, ""]);
                      } else if (data is List<String>) {
                        print("data: $data");
                        try {
                          await walletModal.createWallet(name: walletName, address: data[1], data: data[2], needBackUp: true);
                          setState(() {
                            isLoad = false;
                          });
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          setState(() {
                            isLoad = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: DarkColors.redColor,
                            behavior: SnackBarBehavior.fixed,
                            content: Text(
                              e.toString(),
                              style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white), listen: false),
                            ),
                          ));
                        }
                        isolate?.kill(priority: Isolate.immediate);
                      }
                    });

                    // Future.delayed(const Duration(milliseconds: 1000), () {
                    //   setState(() {
                    //     isLoad = false;
                    //   });
                    //   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DesktopSecurityPage()));
                    // });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
