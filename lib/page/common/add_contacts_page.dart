import 'dart:io';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:scan_qr/scan_qr.dart';

class AddContactsPage extends StatefulWidget {
  final ContactsItem? item;
  final int index;
  final bool isEdit;
  @override
  const AddContactsPage({Key? key, this.item, this.isEdit = false, this.index = 0}) : super(key: key);

  @override
  State<AddContactsPage> createState() => _AddContactsPage();
}

class _AddContactsPage extends State<AddContactsPage> {
  late TextEditingController controller;
  late TextEditingController controller2;
  String error = "";
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller2 = TextEditingController();
    if (widget.item != null) {
      controller.text = widget.item!.address;
      controller2.text = widget.item!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnable = controller.text.isNotEmpty && controller2.text.isNotEmpty;
    if (widget.isEdit) {
      isButtonEnable = controller.text.isNotEmpty && controller2.text.isNotEmpty && (controller.text != widget.item!.address || controller2.text != widget.item!.name);
    }
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
              title: widget.isEdit ? AppLocalizations.of(context).edit_contact : AppLocalizations.of(context).add_contact,
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
                                    error = "";
                                  });
                                  controller.text = res;
                                  controller.selection = TextSelection.fromPosition(TextPosition(offset: res.length));
                                } else {
                                  controller.clear();
                                  controller.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                                  setState(() {
                                    error = AppLocalizations.of(context).walletAddressError;
                                  });
                                }
                              } else {
                                controller.clear();
                                controller.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                                setState(() {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).contact_name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      const SizedBox(height: 13),
                      AutoSizeTextField(
                        controller: controller2,
                        onChanged: (value) {
                          setState(() {
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
                          hintText: AppLocalizations.of(context).contact_name,
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
                      const SizedBox(height: 25),
                      Text(AppLocalizations.of(context).walletAddress, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      const SizedBox(height: 13),
                      AutoSizeTextField(
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
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
                      bool flag = TransactionHelper.checkAddress(controller.text);
                      bool flag2 = Helper.checkName(controller2.text);
                      if (!flag2) {
                        setState(() {
                          error = AppLocalizations.of(context).contact_name_error;
                        });
                        return;
                      }
                      if (flag) {
                        // 添加联系人
                        if (widget.isEdit) {
                          await contacts.changeContacts(index: widget.index, name: controller2.text, address: controller.text);
                        } else {
                          await contacts.addContacts(name: controller2.text, address: controller.text);
                        }
                        if (mounted) Navigator.pop(context);
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
