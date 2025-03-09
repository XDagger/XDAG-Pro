import 'package:flutter/cupertino.dart';
import 'package:xdag/common/global.dart';

class ContactsItem {
  String name;
  String address;
  ContactsItem(this.name, this.address);

  static fromJson(String e) {
    List<String> list = e.split(",");
    return ContactsItem(list[1], list[0]);
  }

  String toJsonString() {
    return "$address,$name";
  }
}

class ContactsModal extends ChangeNotifier {
  List<ContactsItem> get contactsList => Global.contactsListBox;

  updateList() async {
    List<String> list = [];
    for (var i in Global.contactsListBox) {
      if (i.address != 'PKcBtHWDSnAWfZntqWPBLedqBShuKSTzS') {
        list.add(i.toJsonString());
      }
    }
    await Global.prefs.setStringList(Global.contactsListKey, list);
    notifyListeners();
  }

  addContacts({required String name, required String address}) async {
    try {
      ContactsItem item = ContactsItem(name, address);
      // 插入到第一个
      Global.contactsListBox.insert(1, item);
      updateList();
    } catch (e) {
      rethrow;
    }
  }

  changeContacts({required int index, required String address, required String name}) async {
    try {
      ContactsItem item = ContactsItem(name, address);
      Global.contactsListBox[index] = item;
      updateList();
    } catch (e) {
      rethrow;
    }
  }

  deleteContacts({required int index}) async {
    try {
      Global.contactsListBox.removeAt(index);
      updateList();
    } catch (e) {
      rethrow;
    }
  }
}
