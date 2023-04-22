import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/words.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/back_up_page.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/create_wallet_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BackUpStartPage extends StatelessWidget {
  const BackUpStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    double bottomPadding = ScreenHelper.bottomPadding;
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          CreateWalletStep(
            step: 1,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context).secure_wallet, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DarkColors.mainColor))),
                  const SizedBox(height: 50),
                  Expanded(child: Image.asset('images/lock.png', fit: BoxFit.contain)),
                  const SizedBox(height: 50),
                  Text(AppLocalizations.of(context).write_Down_Mnemonics_tips, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context).backup_test_tips_2, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                color: DarkColors.lineColor,
                height: 1,
                width: double.infinity,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 20, 15, bottomPadding > 0 ? bottomPadding : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Button(
                      text: AppLocalizations.of(context).start,
                      bgColor: DarkColors.mainColor,
                      onPressed: () async {
                        await showModalBottomSheet(
                          backgroundColor: DarkColors.bgColor,
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext buildContext) => CheckPage(checkCallback: (bool isCheck) async {
                            if (isCheck) {
                              String? data = await Global.getWalletDataByAddress(wallet.address);
                              if (data != null && context.mounted) {
                                if (data.contains(" ")) {
                                  await Navigator.pushNamed(context, "/back_up", arguments: BackUpPageRouteParams(data, 0, isBackup: true));
                                } else {
                                  await Navigator.pushNamed(context, "/back_up", arguments: BackUpPageRouteParams(data, 1, isBackup: true));
                                }
                              }
                            }
                          }),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class BackUpTestPageRouteParams {
  final String data;
  BackUpTestPageRouteParams(this.data);
}

class BackUpTestPage extends StatefulWidget {
  const BackUpTestPage({super.key});

  @override
  State<BackUpTestPage> createState() => _BackUpTestPageState();
}

class _BackUpTestPageState extends State<BackUpTestPage> {
  late TextEditingController controller;
  final _focusNode1 = FocusNode();
  List<String> mnemonicList = [];
  int mnemonicNumber = 0;
  String errorText = "";
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    _focusNode1.dispose();
    super.dispose();
  }

  void getMnemonicList(String value) {
    if (value.endsWith(" ")) {
      setState(() {
        mnemonicList = [];
        errorText = "";
      });
      return;
    }
    List<String> list = value.trim().split(" ");
    setState(() {
      mnemonicNumber = value.isEmpty ? 0 : list.length;
      errorText = "";
    });
    if (list.isNotEmpty && value != "") {
      String lastWord = list[list.length - 1];
      list.removeLast();
      if (lastWord == " " || lastWord == "") {
        setState(() {
          mnemonicList = [];
        });
      } else {
        List<String> mnemonicList1 = [];
        for (String word in wordList) {
          if (word.startsWith(lastWord) || word == lastWord) {
            mnemonicList1.add(word);
          }
        }
        setState(() {
          mnemonicList = mnemonicList1;
        });
      }
    } else {
      setState(() {
        mnemonicList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    bool isButtonEnable = mnemonicNumber == 12;
    BackUpTestPageRouteParams args = BackUpTestPageRouteParams('');
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as BackUpTestPageRouteParams;
    }
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Column(
          children: [
            CreateWalletStep(
              step: 3,
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context).confirm_Mnemonic, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DarkColors.mainColor))),
                    const SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context).mnemonic_hint_2,
                      style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    AutoSizeTextField(
                      controller: controller,
                      focusNode: _focusNode1,
                      onChanged: (value) {
                        getMnemonicList(value);
                      },
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());
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
                      textInputAction: TextInputAction.done,
                      style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      decoration: InputDecoration(
                        filled: true,
                        contentPadding: const EdgeInsets.all(15),
                        fillColor: DarkColors.blockColor,
                        hintText: AppLocalizations.of(context).mnemonic,
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
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Spacer(),
                        Text('$mnemonicNumber ${mnemonicNumber > 1 ? AppLocalizations.of(context).words : AppLocalizations.of(context).word}', style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white54))),
                      ],
                    ),
                    if (errorText.isNotEmpty)
                      Container(
                        width: ScreenHelper.screenWidth - 40,
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: DarkColors.redColorMask,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(errorText, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500))),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
              ),
            ),
            Container(color: DarkColors.lineColor, height: 1, width: double.infinity),
            KeyboardVisibilityBuilder(
              builder: (context, isKeyboardShow) {
                if (isKeyboardShow) {
                  if (mnemonicList.isEmpty) {
                    return Container();
                  }
                  return SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mnemonicList.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        String word = mnemonicList[index];
                        return TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(20, 0, 20, 0)),
                          ),
                          onPressed: () {
                            String text = controller.text;
                            List<String> list = text.split(" ");
                            list.removeLast();
                            String newText = list.join(" ");
                            controller.text = newText == '' ? "$word " : "$newText $word ";
                            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                            setState(() {
                              mnemonicList = [];
                            });
                          },
                          child: Text(word, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: DarkColors.mainColor))),
                        );
                      },
                    ),
                  );
                } else {
                  return Container(
                    margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Button(
                          text: AppLocalizations.of(context).continueText,
                          bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                          textColor: Colors.white,
                          disable: !isButtonEnable,
                          onPressed: () async {
                            String mnemonic = controller.text.trim();
                            if (mnemonic == args.data.trim()) {
                              await walletModal.setBackUp();
                              if (mounted) {
                                Helper.changeAndroidStatusBarAndNavBar(true);
                                await showCupertinoModalPopup(
                                  context: context,
                                  barrierColor: Colors.black.withOpacity(0.6),
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: DarkColors.bgColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      titlePadding: const EdgeInsets.fromLTRB(12.0, 15.0, 12, 0),
                                      insetPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                                      contentPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                                      actionsPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 20.0),
                                      title: null,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset('images/like.png', width: 100, height: 100),
                                          const SizedBox(height: 20),
                                          Text(
                                            AppLocalizations.of(context).successful,
                                            style: Helper.fitChineseFont(context, const TextStyle(color: DarkColors.mainColor, fontSize: 24.0, fontWeight: FontWeight.w700)),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            AppLocalizations.of(context).backup_test_tips_4,
                                            style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w500)),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            AppLocalizations.of(context).backup_test_tips_5,
                                            style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w500)),
                                          )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Button(
                                              text: AppLocalizations.of(context).continueText,
                                              width: ScreenHelper.screenWidth - 60,
                                              bgColor: DarkColors.mainColor,
                                              onPressed: () => Navigator.pop(context, true),
                                            )
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                                Helper.changeAndroidStatusBarAndNavBar(false);
                                // 返回首页
                                if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            } else {
                              setState(() {
                                mnemonicList = [];
                                errorText = AppLocalizations.of(context).mnemonic_error_1;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
