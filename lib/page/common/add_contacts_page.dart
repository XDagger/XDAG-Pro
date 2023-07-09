import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:scan_qr/scan_qr.dart';

class AddContactsPage extends StatelessWidget {
  final ContactsItem? item;
  final int index;
  final bool isEdit;
  const AddContactsPage({super.key, this.item, this.isEdit = false, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: CommonAddContactsPage(item: item, isEdit: isEdit, index: index),
      ),
    );
  }
}

class CommonAddContactsPage extends StatefulWidget {
  final ContactsItem? item;
  final int index;
  final bool isEdit;
  @override
  const CommonAddContactsPage({Key? key, this.item, this.isEdit = false, this.index = 0}) : super(key: key);

  @override
  State<CommonAddContactsPage> createState() => _CommonAddContactsPage();
}

class _CommonAddContactsPage extends State<CommonAddContactsPage> {
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

  void addContacts() async {
    ContactsModal contacts = Provider.of<ContactsModal>(context, listen: false);
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
        // 检查有没有重复地址
        bool hasRepeat = false;
        for (var i = 0; i < contacts.contactsList.length; i++) {
          if (contacts.contactsList[i].address == controller.text) {
            hasRepeat = true;
            break;
          }
        }
        if (hasRepeat) {
          setState(() {
            error = AppLocalizations.of(context).contact_address_repeat;
          });
          return;
        }
        await contacts.addContacts(name: controller2.text, address: controller.text);
      }
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        error = AppLocalizations.of(context).walletAddressError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ContactsModal contacts = Provider.of<ContactsModal>(context);
    bool isButtonEnable = controller.text.trim().isNotEmpty && controller2.text.isNotEmpty;
    if (widget.isEdit) {
      isButtonEnable = controller.text.trim().isNotEmpty && controller2.text.isNotEmpty && (controller.text != widget.item!.address || controller2.text != widget.item!.name);
    }
    double paddingH = Helper.isDesktop ? 0 : 15;
    double paddingH2 = Helper.isDesktop ? 0 : 20;
    Widget btn = Helper.isDesktop
        ? Container(
            margin: EdgeInsets.fromLTRB(paddingH, 0, paddingH, 0),
            child: Row(
              children: [
                const Spacer(),
                BottomBtn(
                  text: AppLocalizations.of(context).continueText,
                  bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                  disable: !isButtonEnable,
                  onPressed: () => addContacts(),
                ),
              ],
            ),
          )
        : Container(
            margin: EdgeInsets.fromLTRB(paddingH, 20, paddingH, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  text: AppLocalizations.of(context).continueText,
                  width: ScreenHelper.screenWidth - 30,
                  bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                  textColor: Colors.white,
                  disable: !isButtonEnable,
                  onPressed: () => addContacts(),
                ),
              ],
            ),
          );
    return Column(
      children: [
        Helper.isDesktop
            ? const SizedBox()
            : NavHeader(
                title: widget.isEdit ? AppLocalizations.of(context).edit_contact : AppLocalizations.of(context).add_contact,
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
                                  title: AppLocalizations.of(context).error,
                                  content: AppLocalizations.of(context).camera_permissions,
                                  confirmText: AppLocalizations.of(context).setting,
                                  cancelText: AppLocalizations.of(context).cancel,
                                  errQrText: AppLocalizations.of(context).qr_not_found,
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
                                      error = "";
                                    });
                                    controller.text = address;
                                    controller.selection = TextSelection.fromPosition(TextPosition(offset: address.length));
                                    if (json["name"] != null) {
                                      controller2.text = json["name"];
                                      controller2.selection = TextSelection.fromPosition(TextPosition(offset: json["name"].length));
                                    }
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
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(paddingH2, Helper.isDesktop ? 10 : 30, paddingH2, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).contact_name, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
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
                    style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.all(15),
                      fillColor: DarkColors.blockColor,
                      hintText: AppLocalizations.of(context).contact_name,
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
                  const SizedBox(height: 25),
                  Text(AppLocalizations.of(context).walletAddress, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
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
                    style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.all(15),
                      fillColor: DarkColors.blockColor,
                      hintText: AppLocalizations.of(context).walletAddress,
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
                      width: Helper.isDesktop ? 570 : ScreenHelper.screenWidth - 40,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: DarkColors.redColorMask,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(error, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500))),
                    )
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        btn,
      ],
    );
  }
}

class DesktopContactsPage extends StatelessWidget {
  final ContactsItem? item;
  final int index;
  final bool isEdit;
  const DesktopContactsPage({Key? key, this.item, this.index = 0, this.isEdit = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DesktopModalFrame(
        boxSize: const Size(600, 400),
        title: isEdit ? AppLocalizations.of(context).edit_contact : AppLocalizations.of(context).add_contact,
        child: Expanded(
          child: CommonAddContactsPage(item: item, isEdit: isEdit, index: index),
        ));
  }
}
