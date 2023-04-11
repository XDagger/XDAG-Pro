import 'dart:io';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:scan_qr/scan_qr.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => ContactsStatePage();
}

class ContactsStatePage extends State<ContactsPage> {
  late TextEditingController controller;
  String walletAddress = "";
  String error = "";
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnable = walletAddress.isNotEmpty;
    ContactsModal contacts = Provider.of<ContactsModal>(context);
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
              title: "${AppLocalizations.of(context).send} XDAG",
              isColseIcon: true,
              rightWidget: Platform.isIOS || Platform.isAndroid
                  ? Row(children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: DarkColors.blockColor,
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () async {
                            setState(() {
                              error = "";
                            });
                            try {
                              var res = await ScanQr.openScanQr(
                                color: "#15A9EC",
                                title: AppLocalizations.of(context).error,
                                content: AppLocalizations.of(context).camera_permissions,
                                confirmText: AppLocalizations.of(context).setting,
                                cancelText: AppLocalizations.of(context).cancel,
                                errQrText: AppLocalizations.of(context).qr_not_found,
                              );
                              if (res != null) {
                                bool flag = TransactionHelper.checkAddress(res);
                                if (flag) {
                                  setState(() {
                                    walletAddress = res;
                                    error = "";
                                  });
                                  controller.text = res;
                                  controller.selection = TextSelection.fromPosition(TextPosition(offset: res.length));
                                } else {
                                  controller.clear();
                                  controller.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                                  setState(() {
                                    walletAddress = "";
                                    error = AppLocalizations.of(context).walletAddressError;
                                  });
                                }
                              } else {
                                controller.clear();
                                controller.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                                setState(() {
                                  walletAddress = "";
                                  error = AppLocalizations.of(context).walletAddressError;
                                });
                              }
                            } catch (e) {}
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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
                        walletAddress = value;
                        error = "";
                      });
                    },
                    minFontSize: 16,
                    maxLines: 10,
                    minLines: 1,
                    autofocus: true,
                    contextMenuBuilder: (context, editableTextState) {
                      final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: buttonItems,
                      );
                    },
                    textInputAction: TextInputAction.next,
                    keyboardAppearance: Brightness.dark,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'RobotoMono'),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.all(15),
                      fillColor: DarkColors.blockColor,
                      hintText: AppLocalizations.of(context).walletAddress,
                      hintStyle: const TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'RobotoMono',
                        color: Colors.white54,
                      ),
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
                      child: Text(error, style: const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500)),
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
            Expanded(
              child: ListView.builder(
                itemCount: contacts.contactsList.isEmpty ? 2 : contacts.contactsList.length + 1,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                itemBuilder: (BuildContext buildContext, int index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context).contacts,
                          style: const TextStyle(color: Colors.white, fontFamily: 'RobotoMono', fontSize: 22.0, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  } else {
                    if (contacts.contactsList.isEmpty) {
                      return Column(children: [
                        const SizedBox(height: 20),
                        const Icon(Icons.crop_landscape, size: 70, color: Colors.white),
                        Text(AppLocalizations.of(context).no_contacts, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ]);
                    }
                    int pos = index - 1;
                    ContactsItem item = contacts.contactsList[pos];
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        controller.text = item.address;
                        controller.selection = TextSelection.fromPosition(TextPosition(offset: item.address.length));
                        Navigator.pushNamed(
                          context,
                          '/send',
                          arguments: SendPageRouteParams(address: item.address),
                        );
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
                                    style: const TextStyle(color: Colors.white, fontFamily: 'RobotoMono', fontSize: 16.0, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item.address,
                                    style: const TextStyle(color: Colors.white54, fontFamily: 'RobotoMono', fontSize: 12.0, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Button(
                    text: AppLocalizations.of(context).continueText,
                    width: ScreenHelper.screenWidth - 30,
                    bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                    textColor: Colors.white,
                    disable: !isButtonEnable,
                    onPressed: () async {
                      // to send
                      bool flag = TransactionHelper.checkAddress(walletAddress);
                      if (flag) {
                        Navigator.pushNamed(
                          context,
                          '/send',
                          arguments: SendPageRouteParams(address: walletAddress),
                        );
                      } else {
                        setState(() {
                          error = AppLocalizations.of(context).walletAddressError;
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
