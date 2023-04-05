import 'dart:io';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:scan_qr/scan_qr.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
                              // setState(() {
                              //   address = res ?? '';
                              // });
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
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
                          width: ScreenHelper.screenWidth - 40,
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                            color: DarkColors.redColorMask,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(error, style: const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500)),
                        )
                      else
                        const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
              child: Column(
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
