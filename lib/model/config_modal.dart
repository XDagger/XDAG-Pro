import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:xdag/common/global.dart';

class LangItem {
  final String name;
  final Locale? locale;

  LangItem(this.name, this.locale);
}

class ConfigModal extends ChangeNotifier {
  WalletConfig get walletConfig => Global.walletConfig;

  static final List<LangItem> langs = [
    LangItem('auto', null),
    LangItem('English', const Locale('en', 'US')),
    LangItem('简体中文', const Locale('zh', 'CN')),
    LangItem('日本語', const Locale('ja', 'JP')),
    LangItem('Français', const Locale('fr', 'FR')),
    LangItem('Русский', const Locale('ru', 'RU')),
    LangItem('Deutsch', const Locale('de', 'DE')),
  ];
  static final List<String> netWorks = ["MainNet", "TestNet"];

  get local => walletConfig.local == 0 ? window.locale : langs[walletConfig.local].locale!;

  changeLocal(int pos) async {
    await Global.saveLocale(pos);
    notifyListeners();
  }

  savePassword(String password) async {
    await Global.savePassword(password);
    notifyListeners();
  }

  deletePassword() async {
    await Global.deletePassword();
    notifyListeners();
  }

  saveBiometrics(bool biometrics) async {
    await Global.saveBiometrics(biometrics);
    notifyListeners();
  }

  saveReadLegal() async {
    await Global.saveReadLegal();
    notifyListeners();
  }
}
