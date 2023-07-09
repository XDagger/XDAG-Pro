import 'dart:isolate';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/create_wallet_page.dart';
import 'package:xdag/widget/input.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

class DesktopCreateWalletPage extends StatefulWidget {
  final Size boxSize;
  final int type;
  const DesktopCreateWalletPage({super.key, required this.boxSize, this.type = 0});

  @override
  State<DesktopCreateWalletPage> createState() => _DesktopCreateWalletPageState();
}

class _DesktopCreateWalletPageState extends State<DesktopCreateWalletPage> {
  @override
  Widget build(BuildContext context) {
    return DesktopModalFrame(
      boxSize: widget.boxSize,
      title: widget.type == 0 ? AppLocalizations.of(context).createWallet : AppLocalizations.of(context).importWallet,
      child: Expanded(
        child: widget.type == 0 ? const WalletNamePage() : const ImportWalletPage(),
      ),
    );
  }
}

class WalletNamePage extends StatefulWidget {
  final VoidCallback? showBack;
  final String? importContent;
  final bool isPrivateKey;
  const WalletNamePage({super.key, this.showBack, this.importContent = '', this.isPrivateKey = false});

  @override
  State<WalletNamePage> createState() => _WalletNamePageState();
}

class _WalletNamePageState extends State<WalletNamePage> {
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
    return Column(
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
        const SizedBox(height: 25),
        Row(
          children: [
            widget.showBack != null ? BottomBtn(bgColor: DarkColors.blockColor, disable: false, text: AppLocalizations.of(context).back, onPressed: widget.showBack) : const SizedBox(),
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
                // print("walletName: $walletName importContent: ${widget.importContent}");
                // return;
                final receivePort = ReceivePort();
                isolate = await Isolate.spawn(isolateFunction, receivePort.sendPort);
                receivePort.listen((data) async {
                  if (data is SendPort) {
                    var subSendPort = data;
                    subSendPort.send([widget.isPrivateKey, widget.importContent]);
                  } else if (data is List<String>) {
                    // print("data: $data");
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
              },
            ),
          ],
        )
      ],
    );
  }
}

class ImportStylePage extends StatefulWidget {
  //  返回一个字符串的回调函数

  // final VoidCallback? onPressed;
  final void Function(String value, bool v)? onPressed;
  const ImportStylePage({super.key, this.onPressed});

  @override
  State<ImportStylePage> createState() => _ImportStylePageState();
}

class _ImportStylePageState extends State<ImportStylePage> {
  int selectIndex = 0;
  List<String> mnemonicList = [];
  String importContent = "";
  final _focusNode1 = FocusNode();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isButtonEnable = importContent.isNotEmpty;
    if (isButtonEnable) {
      if (selectIndex == 0) {
        List content = importContent.split(" ");
        isButtonEnable = content.length >= 12;
      } else {
        isButtonEnable = importContent.length == 64;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 50,
        decoration: BoxDecoration(color: DarkColors.lineColor54, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: HeaderItem(
                title: AppLocalizations.of(context).mnemonic,
                index: 0,
                selectIndex: selectIndex,
                onPressed: () {
                  controller.clear();
                  setState(() {
                    selectIndex = 0;
                    importContent = "";
                  });
                },
              ),
            ),
            Expanded(
              child: HeaderItem(
                title: AppLocalizations.of(context).privateKey,
                index: 1,
                selectIndex: selectIndex,
                onPressed: () {
                  controller.clear();
                  setState(() {
                    selectIndex = 1;
                    importContent = "";
                  });
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 25),
      Text(selectIndex == 1 ? AppLocalizations.of(context).privateKey : AppLocalizations.of(context).mnemonic, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
      const SizedBox(height: 10),
      AutoSizeTextField(
        controller: controller,
        focusNode: _focusNode1,
        onChanged: (value) {
          setState(() {
            importContent = value;
          });
        },
        keyboardAppearance: Brightness.dark,
        minFontSize: 16,
        maxLines: 10,
        minLines: 3,
        autofocus: true,
        contextMenuBuilder: (context, editableTextState) {
          final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        textInputAction: TextInputAction.next,
        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
        decoration: InputDecoration(
          filled: true,
          contentPadding: const EdgeInsets.all(15),
          fillColor: DarkColors.blockColor,
          hintText: selectIndex == 1 ? AppLocalizations.of(context).privateKey : AppLocalizations.of(context).mnemonic_hint_1,
          hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: DarkColors.mainColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
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
              if (widget.onPressed != null) {
                widget.onPressed!(importContent, selectIndex == 1);
              }
            },
          ),
        ],
      )
    ]);
  }
}

class ImportWalletPage extends StatefulWidget {
  const ImportWalletPage({super.key});

  @override
  State<ImportWalletPage> createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {
  final pageController = PageController();
  String importContent = "";
  bool isPrivateKey = false;
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      itemBuilder: (context, index) {
        if (index == 1) {
          return WalletNamePage(
            importContent: importContent,
            isPrivateKey: isPrivateKey,
            showBack: () {
              pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            },
          );
        }
        return ImportStylePage(
          onPressed: (String p, bool f) {
            setState(() {
              importContent = p;
              isPrivateKey = f;
            });
            pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
          },
        );
      },
    );
  }
}
