import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/page/common/add_contacts_page.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/modal_frame.dart';

class ContactsMainPage extends StatelessWidget {
  const ContactsMainPage({super.key});
  @override
  Widget build(BuildContext context) {
    var topPadding = ScreenHelper.topPadding;
    ContactsModal contacts = Provider.of<ContactsModal>(context);
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          SizedBox(height: topPadding),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  AppLocalizations.of(context).contacts,
                  style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                MyCupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DarkColors.mainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                      backgroundColor: DarkColors.bgColor,
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext buildContext) => const AddContactsPage(),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.contactsList.isNotEmpty ? contacts.contactsList.length : 1,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              itemBuilder: (BuildContext buildContext, int index) {
                if (contacts.contactsList.isEmpty) {
                  return Column(children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.crop_landscape, size: 100, color: Colors.white),
                    Text(AppLocalizations.of(context).no_transactions, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16))),
                    const SizedBox(height: 50),
                  ]);
                }
                // var pos = index - 1;
                ContactsItem item = contacts.contactsList[index];
                return MyCupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    Helper.changeAndroidStatusBar(true);
                    String? reslut = (await Helper.showBottomSheet(
                      context,
                      ContactsDetail(
                        item: item,
                        canEdit: index != 0,
                      ),
                    )) as String?;
                    Helper.changeAndroidStatusBar(false);
                    if (reslut == 'delete') {
                      if (context.mounted) {
                        Helper.changeAndroidStatusBarAndNavBar(true);
                        final shouldDelete = await showCupertinoModalPopup(
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
                              title: Row(
                                children: <Widget>[
                                  MyCupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: DarkColors.blockColor,
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                                    ),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context).attention,
                                          style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700)),
                                        ),
                                      )),
                                  const SizedBox(width: 40)
                                ],
                              ),
                              content: Text(
                                AppLocalizations.of(context).delete_contact,
                                style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500)),
                              ),
                              actions: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Button(
                                      text: AppLocalizations.of(context).continueText,
                                      width: ScreenHelper.screenWidth - 60,
                                      bgColor: DarkColors.redColor,
                                      onPressed: () => Navigator.pop(context, true),
                                    ),
                                    const SizedBox(height: 20),
                                    Button(
                                      text: AppLocalizations.of(context).cancel,
                                      width: ScreenHelper.screenWidth - 60,
                                      bgColor: DarkColors.lineColor,
                                      onPressed: () => Navigator.pop(context, false),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );
                        Helper.changeAndroidStatusBarAndNavBar(false);
                        if (shouldDelete) {
                          contacts.deleteContacts(index: index);
                        }
                      }
                    }
                    if (reslut == 'edit') {
                      if (context.mounted) {
                        showModalBottomSheet(
                          backgroundColor: DarkColors.bgColor,
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext buildContext) => AddContactsPage(
                            item: item,
                            isEdit: true,
                            index: index,
                          ),
                        );
                      }
                    }
                    if (reslut == 'send') {
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          '/send',
                          arguments: SendPageRouteParams(address: item.address, name: item.name),
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: DarkColors.blockColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (index == 0) const Icon(Icons.star, color: DarkColors.yellowColor, size: 16) else const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactsDetail extends StatelessWidget {
  final ContactsItem item;
  final bool canEdit;
  const ContactsDetail({Key? key, required this.item, this.canEdit = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalFrame(
      title: item.name,
      isHideLeftDownButton: true,
      isShowRightCloseButton: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Text(item.name, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400))),
                  // const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: DarkColors.blockColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Text(item.address, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w700))),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
              // color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (canEdit)
                    MyCupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: DarkColors.redColorMask2,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop("delete");
                      },
                    ),
                  if (canEdit)
                    MyCupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: DarkColors.blockColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop("edit");
                      },
                    ),
                  MyCupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: DarkColors.blockColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop("send");
                    },
                  ),
                  MyCupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: DarkColors.blockColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.address));
                      Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
