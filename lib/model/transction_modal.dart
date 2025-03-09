import 'package:flutter/material.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/model/wallet_modal.dart';

class TransactionModal extends ChangeNotifier {
  List<String> getTransactions(String address) {
    return Global.prefs.getStringList(address) ?? [];
  }

  List<Transaction> getTransactionsList(String address) {
    List<String> list = getTransactions(address);
    List<Transaction> transactions = [];
    for (var item in list) {
      transactions.add(Transaction.fromJson(item));
    }
    return transactions;
  }

  void addTransaction(Transaction transaction, String address) {
    List<String> list = getTransactions(address);
    list.add(transaction.toJsonString());
    Global.prefs.setStringList(address, list);
    notifyListeners();
  }

  void removeTransaction(int index, String address) {
    List<String> list = getTransactions(address);
    list.removeAt(index);
    Global.prefs.setStringList(address, list);
    notifyListeners();
  }
}
