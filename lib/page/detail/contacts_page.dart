import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:scan_qr/scan_qr.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => ContactsStatePage();
}

class ContactsStatePage extends State<ContactsPage> {
  late TextEditingController controller;
  bool isButtonEnable = false;
  String error = "";
  int nav = 0;
  final pageController = PageController();
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // bool isButtonEnable = controller.text.isNotEmpty;
    ContactsModal contacts = Provider.of<ContactsModal>(context);
    WalletModal walletModal = Provider.of<WalletModal>(context);
    List<Wallet> walletList = walletModal.getOtherWallet();
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
            NavHeader(
              title: "${AppLocalizations.of(context)!.send} XDAG",
              isColseIcon: true,
              rightWidget: Platform.isIOS || Platform.isAndroid
                  ? Row(children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          color: DarkColors.mainColor,
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () async {
                            setState(() {
                              error = "";
                            });
                            try {
                              var res = await ScanQr.openScanQr(
                                color: "#15A9EC",
                                title: AppLocalizations.of(context)!.error,
                                content: AppLocalizations.of(context)!.camera_permissions,
                                confirmText: AppLocalizations.of(context)!.setting,
                                cancelText: AppLocalizations.of(context)!.cancel,
                                errQrText: AppLocalizations.of(context)!.qr_not_found,
                              );
                              if (res != null) {
                                // 判断 res 是否是一个 json 字符串
                                bool isJosn = TransactionHelper.isJson(res);
                                String address = res;
                                Map<String, dynamic> json = {};
                                bool flag1 = TransactionHelper.checkAddress(address);
                                if (!flag1) {
                                  if (isJosn) {
                                    json = const JsonDecoder().convert(res);
                                    address = json["address"] ?? "";
                                  }
                                }
                                bool flag = TransactionHelper.checkAddress(address);
                                if (flag) {
                                  setState(() {
                                    // walletAddress = res;
                                    isButtonEnable = true;
                                    error = "";
                                  });
                                  controller.text = address;
                                  controller.selection = TextSelection.fromPosition(TextPosition(offset: address.length));
                                  if (mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      '/send',
                                      arguments: SendPageRouteParams(
                                        address: controller.text,
                                        amount: json["amount"] ?? "",
                                        remark: json["remark"] ?? "",
                                        name: json["name"] ?? "",
                                      ),
                                    );
                                  }
                                } else {
                                  controller.clear();
                                  controller.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                                  setState(() {
                                    // walletAddress = "";
                                    isButtonEnable = false;
                                    error = AppLocalizations.of(context)!.walletAddressError;
                                  });
                                }
                              } else {
                                controller.clear();
                                controller.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                                setState(() {
                                  // walletAddress = "";
                                  isButtonEnable = false;
                                  error = AppLocalizations.of(context)!.walletAddressError;
                                });
                              }
                              // ignore: empty_catches
                            } catch (e) {}
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner_outlined, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                    ])
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
              child: Column(
                children: [
                  AutoSizeTextField(
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnable = value.isNotEmpty;
                        error = "";
                      });
                    },
                    minFontSize: 16,
                    maxLines: 10,
                    minLines: 1,
                    autofocus: false,
                    contextMenuBuilder: (context, editableTextState) {
                      final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: buttonItems,
                      );
                    },
                    textInputAction: TextInputAction.next,
                    keyboardAppearance: Brightness.dark,
                    style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.all(15),
                      fillColor: DarkColors.blockColor,
                      hintText: AppLocalizations.of(context)!.walletAddress,
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
                  if (error.isNotEmpty)
                    Container(
                      width: ScreenHelper.screenWidth - 30,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: DarkColors.redColorMask,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(error, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500))),
                    )
                  else
                    const SizedBox(height: 0),
                ],
              ),
            ),
            Container(
              width: ScreenHelper.screenWidth - 30,
              height: 1,
              color: DarkColors.lineColor,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 7, 7, 10),
              child: Row(
                children: [
                  MyCupertinoButton(
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    onPressed: () {
                      if (nav == 0) return;
                      setState(() {
                        nav = 0;
                      });
                      pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.contacts,
                      style: Helper.fitChineseFont(context, TextStyle(color: nav == 0 ? DarkColors.mainColor : Colors.white54, fontSize: 22.0, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyCupertinoButton(
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    onPressed: () {
                      if (nav == 1) return;
                      setState(() {
                        nav = 1;
                      });
                      pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.wallet,
                      style: Helper.fitChineseFont(context, TextStyle(color: nav == 1 ? DarkColors.mainColor : Colors.white54, fontSize: 22.0, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: 2,
                controller: pageController,
                itemBuilder: (context, pos) {
                  bool isContact = pos == 0;
                  int len = isContact ? (contacts.contactsList.isEmpty ? 1 : contacts.contactsList.length) : walletList.length;
                  return ListView.builder(
                    itemCount: len,
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    itemBuilder: (BuildContext buildContext, int index) {
                      if ((contacts.contactsList.isEmpty && isContact) || (walletList.isEmpty && !isContact)) {
                        return Column(children: [
                          const SizedBox(height: 20),
                          const Icon(Icons.crop_landscape, size: 100, color: Colors.white),
                          Text(pos == 0 ? AppLocalizations.of(context)!.no_contacts : AppLocalizations.of(context)!.no_wallets, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 14))),
                        ]);
                      }
                      ContactsItem item = isContact ? contacts.contactsList[index] : ContactsItem(walletList[index].name, walletList[index].address);
                      return MyCupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              '/send',
                              arguments: SendPageRouteParams(address: item.address, name: item.name),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: DarkColors.blockColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500)),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.address,
                                      style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 12.0, fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              if (isContact && index == 0) const Icon(Icons.star, color: DarkColors.yellowColor, size: 16) else const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    nav = index;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Button(
                    text: AppLocalizations.of(context)!.continueText,
                    width: ScreenHelper.screenWidth - 30,
                    bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                    textColor: Colors.white,
                    disable: !isButtonEnable,
                    onPressed: () async {
                      // to send
                      bool flag = TransactionHelper.checkAddress(controller.text);
                      if (flag) {
                        Navigator.pushNamed(
                          context,
                          '/send',
                          arguments: SendPageRouteParams(address: controller.text),
                        );
                      } else {
                        setState(() {
                          error = AppLocalizations.of(context)!.walletAddressError;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
