import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/page/common/add_contacts_page.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});
  @override
  Widget build(BuildContext context) {
    ContactsModal contacts = Provider.of<ContactsModal>(context);
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).contacts,
                style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const Spacer(),
              MyCupertinoButton(
                padding: const EdgeInsets.all(0),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: DarkColors.mainColor, width: 1),
                  ),
                  child: const Icon(Icons.add, size: 20, color: DarkColors.mainColor),
                ),
                onPressed: () {
                  showDialog(context: context, builder: (BuildContext context) => const DesktopContactsPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.contactsList.isNotEmpty ? contacts.contactsList.length : 1,
              itemBuilder: (BuildContext buildContext, int index) {
                if (contacts.contactsList.isEmpty) {
                  return Column(children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.crop_landscape, size: 100, color: Colors.white),
                    Text(AppLocalizations.of(context).no_transactions, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16))),
                    const SizedBox(height: 50),
                  ]);
                }
                ContactsItem item = contacts.contactsList[index];
                return Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(height: 5),
                                SelectableText(
                                  item.address,
                                  style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 14.0, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          index == 0
                              ? const SizedBox()
                              : MyCupertinoButton(
                                  padding: const EdgeInsets.all(0),
                                  child: const SizedBox(width: 32, height: 32, child: Icon(Icons.delete, size: 20, color: DarkColors.redColor)),
                                  onPressed: () async {
                                    final shouldDelete = await await showDialog(
                                      context: context,
                                      builder: (BuildContext context) => DesktopAlertModal(
                                        title: AppLocalizations.of(context).attention,
                                        content: AppLocalizations.of(context).delete_contact,
                                      ),
                                    );
                                    if (shouldDelete) {
                                      await contacts.deleteContacts(index: index);
                                    }
                                  },
                                ),
                          const SizedBox(width: 18),
                          index == 0
                              ? const SizedBox(width: 32, height: 32, child: Icon(Icons.star, size: 20, color: DarkColors.yellowColor))
                              : MyCupertinoButton(
                                  padding: const EdgeInsets.all(0),
                                  child: const SizedBox(width: 32, height: 32, child: Icon(Icons.edit, size: 20, color: Colors.white)),
                                  onPressed: () => showDialog(context: context, builder: (BuildContext context) => DesktopContactsPage(item: item, index: index, isEdit: true)),
                                ),
                          // const SizedBox(width: 18),
                          // MyCupertinoButton(
                          //   padding: const EdgeInsets.all(0),
                          //   child: const SizedBox(width: 32, height: 32, child: Icon(Icons.send, size: 20, color: Colors.white)),
                          //   onPressed: () async {},
                          // ),
                        ],
                      ),
                      Container(margin: const EdgeInsets.fromLTRB(0, 15, 0, 0), height: 1, color: Colors.white30)
                    ],
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
