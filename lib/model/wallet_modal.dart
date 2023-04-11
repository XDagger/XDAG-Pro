import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/model/db_model.dart';
import 'package:dio/dio.dart';

class Transaction {
  final String time;
  final String amount;
  final String address;
  final String status;
  final String from;
  final String to;
  final int type;
  final double fee;
  final String hash;
  final String blockAddress;
  final String remark;
  Transaction({required this.time, required this.amount, required this.address, required this.status, required this.from, required this.to, required this.type, required this.hash, required this.fee, required this.blockAddress, required this.remark});
}

class WalletModal extends ChangeNotifier {
  Box<Wallet> get walletList => Global.walletListBox;
  final dio = Dio();
  Wallet? get defaultWallet {
    // 从_wallets列表中查找第一个isDef属性为true的Wallet对象
    for (var i = 0; i < walletList.length; i++) {
      Wallet? wallet = walletList.getAt(i);
      if (wallet != null && wallet.isDef) {
        return wallet;
      }
    }
    // 如果找不到isDef属性为true的Wallet对象，则返回null
    return null;
  }

  Wallet getWallet() {
    return defaultWallet ?? Wallet('', '', '', true, true);
  }

  createWallet({required String name, required String address, required String data, bool needBackUp = false}) async {
    try {
      Wallet newWallet = await Global.createWallet(
        name: name,
        address: address,
        data: data,
        needBackUp: needBackUp,
      );
      await changeSelect(newWallet);
    } catch (e) {
      rethrow;
    }
  }

  changeSelect(Wallet wallet) async {
    Wallet? defWallet = defaultWallet;
    if (defWallet != null) {
      defWallet.isDef = false;
      await defWallet.save();
    }
    wallet.isDef = true;
    await wallet.save();
    notifyListeners();
  }

  changeName(String name) async {
    Wallet? wallet = defaultWallet;
    if (wallet != null) {
      wallet.name = name;
      await wallet.save();
      notifyListeners();
    }
  }

  deleteWallet(Wallet wallet, int index) async {
    bool isDef = wallet.isDef;
    await Global.deleteWallet(wallet.address);
    // await wallet.delete();
    await walletList.deleteAt(index);
    if (walletList.isNotEmpty && isDef) {
      Wallet? currentWallet = walletList.getAt(0);
      if (currentWallet != null) {
        changeSelect(currentWallet);
        return;
      }
    }
    notifyListeners();
  }

  setBlance(String amount) async {
    Wallet? wallet = defaultWallet;
    if (wallet != null) {
      wallet.amount = double.parse(amount).toStringAsFixed(2);
      await wallet.save();
      notifyListeners();
    }
  }

  setBackUp() async {
    Wallet? wallet = defaultWallet;
    if (wallet != null) {
      wallet.isBackup = true;
      await wallet.save();
      notifyListeners();
    }
  }
}
