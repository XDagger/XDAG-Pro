import 'dart:io';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => ContactsStatePage();
}

class ContactsStatePage extends State<ContactsPage> {
  late TextEditingController controller;
  String walletAddress = "";
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
              // rightWidget: Platform.isIOS || Platform.isAndroid
              //     ? Row(children: [
              //         SizedBox(
              //           width: 40,
              //           height: 40,
              //           child: CupertinoButton(
              //             padding: EdgeInsets.zero,
              //             color: DarkColors.blockColor,
              //             borderRadius: BorderRadius.circular(20),
              //             onPressed: () async {
              //               var receiver = FlutterBarcodeScanner.getBarcodeStreamReceiver("#15A9EC", AppLocalizations.of(context).cancel, false, ScanMode.QR)?.listen((barcode) {
              //                 /// barcode to be used
              //                 print(barcode);
              //                 receiver.cancel();
              //               });
              //             },
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: const [
              //                 Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
              //               ],
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 15),
              //       ])
              //     : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: AutoSizeTextField(
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        walletAddress = value;
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
                  // TextField(
                  //   controller: controller,
                  //   onChanged: (value) {
                  //     // widget.onChanged(value);
                  //     setState(() {
                  //       walletAddress = value;
                  //     });
                  //   },
                  //   autofocus: true,
                  //   maxLines: 1,
                  //   cursorColor: DarkColors.mainColor,
                  //   style: const TextStyle(
                  //     decoration: TextDecoration.none,
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w500,
                  //     fontFamily: 'RobotoMono',
                  //     color: Colors.white,
                  //   ),
                  //   decoration: InputDecoration(
                  //     hintText: AppLocalizations.of(context).walletAddress,
                  //     filled: true,
                  //     fillColor: DarkColors.blockColor,
                  //     contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  //     hintStyle: const TextStyle(
                  //       decoration: TextDecoration.none,
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w500,
                  //       fontFamily: 'RobotoMono',
                  //       color: Colors.white54,
                  //     ),
                  //     focusedBorder: const OutlineInputBorder(
                  //       borderSide: BorderSide(color: DarkColors.mainColor, width: 1),
                  //       borderRadius: BorderRadius.all(Radius.circular(10)),
                  //     ),
                  //     border: const OutlineInputBorder(
                  //       borderSide: BorderSide.none,
                  //       borderRadius: BorderRadius.all(Radius.circular(10)),
                  //     ),
                  //   ),
                  // ),
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
                      Navigator.pushNamed(
                        context,
                        '/send',
                        arguments: SendPageRouteParams(address: walletAddress),
                      );
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
