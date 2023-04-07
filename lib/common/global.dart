import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:xdag/model/db_model.dart';

class WalletConfig {
  int local;
  bool hasSetPassword;
  bool hasSetBiometrics;
  String walletAddress;
  bool hasReadLegal;

  WalletConfig({this.local = 0, this.hasSetPassword = false, this.hasSetBiometrics = false, this.walletAddress = "", this.hasReadLegal = false});
}

class Global {
  static late WalletConfig walletConfig;
  static late Box<Wallet> walletListBox;
  static late int devBiometricsType;

  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _storage;
  static const String _localeKey = 'localeKey';
  static const String _readLegalKey = 'readLegalKey';
  static const String _passwordKey = 'passwordKey';
  static const String _biometricsKey = 'biometricsKey';
  static const String _hasRunBeforeKey = 'hasRunBeforeKey';
  static const String walletListKey = 'walletListKey';

  static String version = '';
  static String buildNumber = '';

  static const String rpcURL = 'https://testnet-rpc.xdagj.org';
  static const String explorURL = 'https://testexplorer.xdag.io/api';
  static const bool isTest = false;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _storage = Platform.isAndroid ? const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true)) : const FlutterSecureStorage();
    if (_prefs.getBool(_hasRunBeforeKey) != true) {
      await _storage.deleteAll();
      _prefs.setBool(_hasRunBeforeKey, true);
    }
    walletConfig = WalletConfig(local: 0, hasSetPassword: false, hasSetBiometrics: false);
    walletListBox = await Hive.openBox<Wallet>(walletListKey);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    await checkBiometricType();
    await updateConfig();
  }

  static updateConfig() async {
    // locale
    int locale = _prefs.getInt(_localeKey) ?? 0;
    // secure
    bool hasSetPassword = await _storage.containsKey(key: _passwordKey);
    bool hasSetBiometrics = _prefs.getBool(_biometricsKey) ?? false;
    // readLegalKey
    bool hasReadLegal = _prefs.getBool(_readLegalKey) ?? false;
    // init
    walletConfig.local = locale;
    walletConfig.hasSetPassword = hasSetPassword;
    walletConfig.hasSetBiometrics = hasSetBiometrics;
    walletConfig.hasReadLegal = hasReadLegal;
  }

  static saveLocale(int index) async {
    await _prefs.setInt(_localeKey, index);
    walletConfig.local = index;
  }

  static savePassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
    walletConfig.hasSetPassword = true;
  }

  static deletePassword() async {
    await _storage.delete(key: _passwordKey);
    walletConfig.hasSetPassword = false;
  }

  static checkPassword(String password) async {
    String? savedPassword = await _storage.read(key: _passwordKey);
    return savedPassword == password;
  }

  static saveBiometrics(bool biometrics) async {
    await _prefs.setBool(_biometricsKey, biometrics);
    walletConfig.hasSetBiometrics = biometrics;
  }

  static Future<int> checkBiometricType() async {
    int biometricsType = -1;
    if (Platform.isAndroid || Platform.isIOS) {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      if (canAuthenticate) {
        final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
        if (availableBiometrics.contains(BiometricType.face)) {
          biometricsType = 0;
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          biometricsType = 1;
        } else if (availableBiometrics.contains(BiometricType.strong)) {
          biometricsType = 2;
        }
      }
      devBiometricsType = biometricsType;
    }

    return biometricsType;
    // return await _storage.read(key: _biometrics);
  }

  static Future<bool> authenticate(String title, String cancelButton) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
          localizedReason: title,
          authMessages: [
            AndroidAuthMessages(
              signInTitle: title,
              cancelButton: cancelButton,
            ),
            IOSAuthMessages(
              cancelButton: cancelButton,
            ),
          ],
          options: const AuthenticationOptions(biometricOnly: true, sensitiveTransaction: false));
    } on PlatformException catch (e) {
      // print(e);
    }
    return authenticated;
  }

  static saveReadLegal() async {
    await _prefs.setBool(_readLegalKey, true);
    walletConfig.hasReadLegal = true;
  }

  static createWallet({required String name, required String address, required String data, bool needBackUp = false}) async {
    try {
      String? res = await _storage.read(key: address);
      if (res != null) {
        throw Exception("address exist");
      }
      Wallet wallet = Wallet(name, "0.00", address, true, !needBackUp);
      await _storage.write(key: address, value: data);
      await walletListBox.add(wallet);
      return wallet;
    } catch (e) {
      rethrow;
    }
  }

  static deleteWallet(String address) async {
    await _storage.delete(key: address);
  }

  static Future<String> getWalletByAddress(String address) async {
    String? data = await _storage.read(key: address);
    if (data == null) {
      throw Exception("address not exist");
    }
    return data;
  }

  static Future<String?> getWalletDataByAddress(String address) async {
    return await _storage.read(key: address);
  }
}
